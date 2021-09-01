create or replace PACKAGE BODY SESSIONS_CONTROL AS
----------------------------------------------------------------------------------------------------------------   
  procedure error_killing_write(schema in varchar2, PROGRAM_NAME in varchar2, sid in number) 
  is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    update www_server.RUN_PROGRAMS_LOG  t set t.action='ERROR KILLING', t.DATE_END_LOG=SYSDATE where t.schema = error_killing_write.schema and t.PROGRAM_NAME = error_killing_write.PROGRAM_NAME and t.SID = error_killing_write.SID;
    commit;
  end;
----------------------------------------------------------------------------------------------------------------     
  procedure find_to_kill
  is
    check_ pls_integer;
    is_find_session boolean;
    marked_for_kill EXCEPTION;
    PRAGMA EXCEPTION_INIT (marked_for_kill,-31);
  begin
    for l_log in (select SCHEMA, PROGRAM_NAME,SID,SERIAL#,INSTANCE,ACTION,DATE_RUN_LOG,DATE_END_LOG,ADITIONAL_INFO,PROGRAM_TYPE from www_server.RUN_PROGRAMS_LOG t where t.action in ('KILL PROGRAM','KILL JOB')) loop  
      begin
          -----------------------------проверяем залочена ли строка,если for ничего не дает,значит залочена
          check_:=0;
          for temp in (select t.schema  from www_server.RUN_PROGRAMS_LOG  t where t.schema = l_log.schema and t.PROGRAM_NAME = l_log.PROGRAM_NAME and t.SID = l_log.SID and t.action in ('KILL PROGRAM','KILL JOB') for update skip locked) loop
            update www_server.RUN_PROGRAMS_LOG  t set t.action='START KILLING' where t.schema = l_log.schema and t.PROGRAM_NAME = l_log.PROGRAM_NAME and t.SID = l_log.SID;
            check_:=1;
          end loop;   
          commit;
          if(check_=0) then
            continue;
          end if;
          ---------------------------
        
          CASE l_log.ACTION
          WHEN 'KILL JOB' THEN
            for l_sess in ( select serial#, status, t.USERNAME from gv$session t 
                            where t.sid = l_log.sid 
                            and t.USERNAME = l_log.schema 
                            and t.INST_ID = l_log.instance 
                            and t.action = l_log.PROGRAM_NAME
                            and t.MODULE = 'DBMS_SCHEDULER'
                            and t.USERNAME is not null
                            and nvl(t.USERNAME,'ORACLE') not in ('SYS','SYSTEM','ORACLE')
                            and rownum=1
                          )
            loop
              begin
                DBMS_OUTPUT.PUT_LINE('ALTER SYSTEM KILL SESSION '''||l_log.sid||', '||l_sess.serial#||', @'||l_log.instance||''' IMMEDIATE');
                execute immediate 'ALTER SYSTEM KILL SESSION '''||l_log.sid||', '||l_sess.serial#||', @'||l_log.instance||''' IMMEDIATE';
                
                update www_server.RUN_PROGRAMS_LOG  t set t.action='KILLED' where t.schema = l_log.schema and t.PROGRAM_NAME = l_log.PROGRAM_NAME and t.SID = l_log.SID and t.program_type='JOB';
                commit;
                is_find_session := TRUE;
              exception 
              when marked_for_kill then
                update www_server.RUN_PROGRAMS_LOG  t set t.action='KILLED' where t.schema = l_log.schema and t.PROGRAM_NAME = l_log.PROGRAM_NAME and t.SID = l_log.SID and t.program_type='JOB';
                commit;
                is_find_session := TRUE;
              when others then
                  error_killing_write( l_log.schema, l_log.PROGRAM_NAME, l_log.sid ); 
                  RAISE;
              end;
            end loop;
            if( is_find_session = FALSE ) then
              RAISE_APPLICATION_ERROR(-20003, 'Session not found in gv$sessions!');
            end if;
            
          WHEN 'KILL PROGRAM' THEN
            null;
          ELSE
            null;
          END CASE;
          
      exception when others then
            error_killing_write( l_log.schema, l_log.PROGRAM_NAME, l_log.sid ); 
             DBMS_OUTPUT.PUT_LINE(dbms_utility.format_error_stack||'; '||dbms_utility.format_error_backtrace);
            RAISE;
      end;
    end loop;
  end;
----------------------------------------------------------------------------------------------------------------  
  
  
  
END SESSIONS_CONTROL; 
