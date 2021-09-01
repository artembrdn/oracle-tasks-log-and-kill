create or replace package body programs_log is
    l_elapse_time_last PLS_INTEGER:=null;
---------------------------------------------------------------------------------------------------------------------  
  procedure add#( SCHEMA IN VARCHAR2
                , PROGRAM_NAME IN VARCHAR2
                , INFO IN VARCHAR2  default null
                , TASK_ID IN NUMBER default null
                , SID IN NUMBER default null
                , SERIAL# IN NUMBER default null
                , INSTANCE IN NUMBER default null
                , ADITIONAL_INFO IN VARCHAR2 default null)
  IS
      
      
      function find_and_change_log   return PLS_INTEGER
      IS
        TYPE find_curtype IS REF CURSOR;
        find_curvar find_curtype;
        
        CURSOR find_program_in_logs
        IS
          SELECT /*+ noparallel */ * FROM RUN_PROGRAMS_LOG t
            WHERE t.SCHEMA = UPPER(add#.SCHEMA) and t.PROGRAM_NAME = UPPER(add#.PROGRAM_NAME) and t.SID = nvl( add#.SID, sys_context( 'USERENV','SID' )  )
            FOR UPDATE;
        
        find_rec RUN_PROGRAMS_LOG%ROWTYPE; 
        is_updated BOOLEAN;
      BEGIN
          
          OPEN find_program_in_logs;
          LOOP
            FETCH find_program_in_logs INTO find_rec;
            EXIT WHEN find_program_in_logs%NOTFOUND;
            
            UPDATE /*+ noparallel */ RUN_PROGRAMS_LOG t 
              SET 
              t.date_end_log = null,
              t.date_run_log = SYSDATE,
              t.INFO = add#.INFO,
              t.TASK_ID = add#.TASK_ID,
              t.SID = nvl( add#.SID, sys_context( 'USERENV','SID' )),
              t.SERIAL# = add#.SERIAL#,
              t.INSTANCE = nvl( add#.INSTANCE, sys_context( 'USERENV','INSTANCE' )),
              t.ACTION = 'RUN',
              t.ADITIONAL_INFO = UPPER(add#.ADITIONAL_INFO)
              WHERE CURRENT OF find_program_in_logs;
            COMMIT;
            is_updated := TRUE;
            EXIT;
          END LOOP;
          CLOSE find_program_in_logs;
            
          IF ( is_updated ) THEN
            return 1;
          ELSE
            return 0;
          END IF;
      END find_and_change_log;
      
      
      procedure insert_new_log
      IS
      BEGIN
        INSERT /*+ noparallel */ INTO RUN_PROGRAMS_LOG( SCHEMA, PROGRAM_NAME, INFO , TASK_ID, SID, SERIAL#, INSTANCE, ACTION, DATE_RUN_LOG, ADITIONAL_INFO, program_type)
        VALUES ( UPPER(add#.SCHEMA), UPPER(add#.PROGRAM_NAME), add#.INFO , add#.TASK_ID, nvl( add#.SID, sys_context( 'USERENV','SID' )  ), 
                  add#.SERIAL#, nvl( add#.INSTANCE, sys_context( 'USERENV','INSTANCE' )  ), 'RUN', SYSDATE, UPPER(add#.ADITIONAL_INFO), 'PROGRAM');
        commit;
      END insert_new_log;
      
  BEGIN
  
    IF( add#.SCHEMA is null or add#.PROGRAM_NAME is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    IF ( find_and_change_log() != 1 ) THEN
      insert_new_log();
    END IF;
    
  END add#;
---------------------------------------------------------------------------------------------------------------------
--функция перегружена,т.к. job может быть запущен только один=>его имя уникально в таблице, следовательно,если встречаем старую запись,удаляем все записи относящиеся к ней
  procedure add#( SCHEMA IN VARCHAR2
                , JOB_NAME IN VARCHAR2
                , INFO IN VARCHAR2  default null
                , TASK_ID IN NUMBER default null
                , SID IN NUMBER default null
                , SERIAL# IN NUMBER default null
                , INSTANCE IN NUMBER default null
                , ADITIONAL_INFO IN VARCHAR2 default null)
  IS
      
      
      procedure delete_old_logs
      IS
        TYPE find_curtype IS REF CURSOR;
        find_curvar find_curtype;
        
        CURSOR find_program_in_logs
        IS
          SELECT /*+ noparallel */ * FROM RUN_PROGRAMS_LOG t
            WHERE t.SCHEMA = UPPER(add#.SCHEMA) and t.PROGRAM_NAME = UPPER(add#.JOB_NAME) and t.PROGRAM_TYPE = 'JOB'
            FOR UPDATE;
        
        find_rec RUN_PROGRAMS_LOG%ROWTYPE; 
      BEGIN
          
          OPEN find_program_in_logs;
          LOOP
            FETCH find_program_in_logs INTO find_rec;
            EXIT WHEN find_program_in_logs%NOTFOUND;
            
            delete#( find_rec.SCHEMA, job_name => find_rec.PROGRAM_NAME );
            COMMIT;
            
            EXIT;
          END LOOP;
          CLOSE find_program_in_logs;
            
      END delete_old_logs;
      
      
      procedure insert_new_log
      IS
      BEGIN
        INSERT /*+ noparallel */ INTO RUN_PROGRAMS_LOG( SCHEMA, PROGRAM_NAME, INFO , TASK_ID, SID, SERIAL#, INSTANCE, ACTION, DATE_RUN_LOG, ADITIONAL_INFO, program_type)
        VALUES ( UPPER(add#.SCHEMA), UPPER(add#.JOB_NAME), add#.INFO , add#.TASK_ID, nvl( add#.SID, sys_context( 'USERENV','SID' )  ), add#.SERIAL#, nvl( add#.INSTANCE, sys_context( 'USERENV','INSTANCE' )  ), 'RUN', SYSDATE, UPPER(add#.ADITIONAL_INFO), 'JOB');
        commit;
      END insert_new_log;
      
      
  BEGIN
  
    IF( add#.SCHEMA is null or add#.JOB_NAME is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    delete_old_logs();
    insert_new_log();
    
  END add#;
---------------------------------------------------------------------------------------------------------------------
  procedure edit#( SCHEMA IN VARCHAR2
                , PROGRAM_NAME IN VARCHAR2
                , INFO IN VARCHAR2  default null
                , TASK_ID IN NUMBER default null
                , SID IN NUMBER default null
                , SERIAL# IN NUMBER default null
                , INSTANCE IN NUMBER default null
                , ADITIONAL_INFO IN VARCHAR2 default null)
  IS
      
      
      function find_and_change_log   return PLS_INTEGER
      IS
        TYPE find_curtype IS REF CURSOR;
        find_curvar find_curtype;
        
        CURSOR find_program_in_logs
        IS
          SELECT /*+ noparallel */ * FROM RUN_PROGRAMS_LOG t
            WHERE t.SCHEMA = UPPER(edit#.SCHEMA) and t.PROGRAM_NAME = UPPER(edit#.PROGRAM_NAME) and t.SID = nvl( edit#.SID, sys_context( 'USERENV','SID' )  )
            FOR UPDATE;
        
        find_rec RUN_PROGRAMS_LOG%ROWTYPE; 
        is_updated BOOLEAN;
      BEGIN
          
          OPEN find_program_in_logs;
          LOOP
            FETCH find_program_in_logs INTO find_rec;
            EXIT WHEN find_program_in_logs%NOTFOUND;
            
            UPDATE /*+ noparallel */ RUN_PROGRAMS_LOG t 
              SET 
              t.date_end_log = null,
              t.date_run_log = SYSDATE,
              t.INFO = edit#.INFO,
              t.TASK_ID = edit#.TASK_ID,
              t.SID = nvl( edit#.SID, sys_context( 'USERENV','SID' )),
              t.SERIAL# = edit#.SERIAL#,
              t.INSTANCE = edit#.INSTANCE,
              t.ACTION = 'RUN',
              t.ADITIONAL_INFO = edit#.ADITIONAL_INFO
              WHERE CURRENT OF find_program_in_logs;
            COMMIT;
            is_updated := TRUE;
            EXIT;
          END LOOP;
          CLOSE find_program_in_logs;
            
          IF ( is_updated ) THEN
            return 1;
          ELSE
            return 0;
          END IF;
      END find_and_change_log;
      
      
      procedure insert_new_log
      IS
      BEGIN
        INSERT INTO /*+ noparallel */ RUN_PROGRAMS_LOG( SCHEMA, PROGRAM_NAME, INFO , TASK_ID, SID, SERIAL#, INSTANCE, ACTION, DATE_RUN_LOG, ADITIONAL_INFO)
        VALUES ( UPPER(edit#.SCHEMA), UPPER(edit#.PROGRAM_NAME), edit#.INFO , edit#.TASK_ID, nvl( edit#.SID, sys_context( 'USERENV','SID' )  ), edit#.SERIAL#, nvl( edit#.INSTANCE, sys_context( 'USERENV','INSTANCE' )  ), 'RUN', SYSDATE, UPPER(edit#.ADITIONAL_INFO));
        commit;
      END insert_new_log;
      
      
  BEGIN
  
    IF( edit#.SCHEMA is null or ( edit#.PROGRAM_NAME is null or edit#.SID is null ) ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    IF ( find_and_change_log() != 1 ) THEN
      insert_new_log();
    END IF;
    
  END edit#;
---------------------------------------------------------------------------------------------------------------------
  procedure delete#( SCHEMA IN VARCHAR2, PROGRAM_NAME IN VARCHAR2)
  IS
  BEGIN
    
    IF( delete#.SCHEMA is null or  delete#.PROGRAM_NAME is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    delete from RUN_PROGRAMS_LOG t where t.SCHEMA = UPPER(delete#.SCHEMA) and t.PROGRAM_NAME = UPPER(delete#.PROGRAM_NAME) and t.SID = sys_context( 'USERENV','SID' );
    commit;
    
  END delete#;
---------------------------------------------------------------------------------------------------------------------
  procedure delete#( SCHEMA IN VARCHAR2, JOB_NAME IN VARCHAR2)
  IS
  BEGIN
    
    IF( delete#.SCHEMA is null or  delete#.JOB_NAME is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    delete /*+ noparallel */ from RUN_PROGRAMS_LOG t where t.SID = ( select SID from RUN_PROGRAMS_LOG t1 where t1.SCHEMA = UPPER(delete#.SCHEMA) and t1.PROGRAM_NAME = UPPER(delete#.JOB_NAME) and t1.PROGRAM_TYPE = 'JOB' )
      and t.SCHEMA = UPPER(delete#.SCHEMA);
    commit;
    
  END delete#;
---------------------------------------------------------------------------------------------------------------------  
  procedure kill#( SCHEMA IN VARCHAR2, JOB_NAME IN VARCHAR2)
  IS
  BEGIN
    
    IF( kill#.SCHEMA is null or  kill#.JOB_NAME is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    update /*+ noparallel */ RUN_PROGRAMS_LOG t SET
      t.ACTION='KILL JOB',
      t.date_end_log=SYSDATE
      where t.SCHEMA = UPPER(kill#.SCHEMA) and t.PROGRAM_NAME = UPPER(kill#.JOB_NAME) and t.PROGRAM_TYPE = 'JOB'; 
    commit;
    
  END kill#;
---------------------------------------------------------------------------------------------------------------------  
  procedure kill#( SCHEMA IN VARCHAR2, ADITIONAL_INFO in varchar2, TASK_ID in number)
  IS
    l_sid number;
  BEGIN
    
    IF( kill#.SCHEMA is null or  kill#.ADITIONAL_INFO is null or kill#.TASK_ID is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    begin
      SELECT /*+ noparallel */ t.sid INTO l_sid from RUN_PROGRAMS_LOG t where t.SCHEMA = UPPER(kill#.SCHEMA) and  t.ADITIONAL_INFO = UPPER(kill#.ADITIONAL_INFO) and  t.TASK_ID = kill#.TASK_ID and rownum=1;
    exception when no_data_found then
      RAISE_APPLICATION_ERROR(-20001, 'Program with running task_id '||kill#.task_id||' not found!');
    end;
    
    update /*+ noparallel */ RUN_PROGRAMS_LOG t SET
      t.ACTION='KILL JOB',
      t.task_id=kill#.task_id,
      t.date_end_log=SYSDATE
      where t.SCHEMA = UPPER(kill#.SCHEMA) and t.PROGRAM_type = 'JOB' and t.SID = l_sid; 
    commit;
    
  END kill#;
---------------------------------------------------------------------------------------------------------------------  
  procedure kill#( SCHEMA IN VARCHAR2, PROGRAM_NAME IN VARCHAR2, SID in number default null)
  IS
  BEGIN
    
    IF( kill#.SCHEMA is null or  kill#.PROGRAM_NAME is null ) THEN
      RAISE_APPLICATION_ERROR(-20000, 'Program and schema must be specified');
    END IF;
    
    --функция перегружена,т.к. job может быть запущен только один=>его имя уникально в таблице, а вот обычная программа может запускаться одновременно много раз,отлличается только sid
    if(kill#.sid is null) then
      update /*+ noparallel */ RUN_PROGRAMS_LOG t SET
        t.ACTION='KILL PROGRAM',
        t.date_end_log=SYSDATE
        where t.SCHEMA = UPPER(kill#.SCHEMA) and t.PROGRAM_NAME = UPPER(kill#.PROGRAM_NAME); 
    else
      update /*+ noparallel */ RUN_PROGRAMS_LOG t SET
        t.ACTION='KILL PROGRAM',
        t.date_end_log=SYSDATE
        where t.SCHEMA = UPPER(kill#.SCHEMA) and t.PROGRAM_NAME = UPPER(kill#.PROGRAM_NAME) and t.SID = kill#.SID; 
    end if;
    commit;
    
  END kill#;
---------------------------------------------------------------------------------------------------------------------  
---------------------------------------------------------------------------------------------------------------------  
  procedure elapse_time_start IS
  BEGIN
      l_elapse_time_last := DBMS_UTILITY.get_time;
  END elapse_time_start;
--------------------------------------------------------------------------------------------------------------------- 
  function elapse_time_get(m_elapse_time_start in PLS_INTEGER default null) return number is
      c_big_number number := 4294967296; --2 в 32
      l_elapse_time_curr PLS_INTEGER;
      l_elapse_time_last_temp  PLS_INTEGER;
  BEGIN
      if l_elapse_time_last is null then
          RAISE_APPLICATION_ERROR(-20000, 'Procedure elapse_time_start must be started before this function');
      end if;
      l_elapse_time_curr := DBMS_UTILITY.get_time;
      l_elapse_time_last_temp := nvl(m_elapse_time_start,l_elapse_time_last);
      l_elapse_time_last := l_elapse_time_curr; --сессионная переменная
      
      return MOD( (l_elapse_time_curr - l_elapse_time_last_temp) + c_big_number, c_big_number);
  END elapse_time_get;
---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------- 
  function elapse_time_get_last return number IS
  BEGIN
      if l_elapse_time_last is null then
          RAISE_APPLICATION_ERROR(-20000, 'Procedure elapse_time_start must be started before this function');
      end if;
      return l_elapse_time_last;
  END elapse_time_get_last;
---------------------------------------------------------------------------------------------------------------------
end programs_log;
