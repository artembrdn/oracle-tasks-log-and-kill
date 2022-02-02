# Oracle tasks-log-and-kill

📝 A mechanism for logging and killing tasks on demand without using DBMS_APPLICATION_INFO.


##### USAGE:  
* at the very beginning of the program body
    >     programs_log.add#(
    >       SCHEMA => 'www_server', 
    >       JOB_NAME => 'JOB_NAME', 
    >       info=>'job поиск пользователей',
    >       sid => sys_context( 'USERENV','SID' ),
    >       aditional_info=>'FIND_USERS'
    >     );
    or  

    >     programs_log.add#(
    >       SCHEMA => 'www_server',
    >       program_name=>'FIND_USERS.find', 
    >       task_id => find.task_id, 
    >       aditional_info=>'FIND_USERS'
    >     );
* at the end of the program body 
    >     programs_log.delete#( SCHEMA => 'www_server', JOB_NAME => find_run.JOB_NAME );

* to kill program / job
    >     programs_log.kill#( 
    >       schema=> 'www_server', 
    >       aditional_info=>'FIND_USERS', 
    >       task_id => kill_task.task_id
    >     );
    or
    >     programs_log.kill#( 
    >       schema=> 'www_server', 
    >       JOB_NAME=>'JOB1'
    >     );
