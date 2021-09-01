# oracle-tasks-log-and-kill
A mechanism for logging and killing tasks on demand without using DBMS_APPLICATION_INFO



programs_log.add#('www_server', JOB_NAME => find_run.JOB_NAME, info=>'job поиск пользователей',sid => sys_context( 'USERENV','SID' ),aditional_info=>'FIND_USERS');
programs_log.add#('www_server',program_name=>'FIND_USERS.find', task_id => find.task_id, aditional_info=>'FIND_USERS');
 
programs_log.delete#( 'www_server', JOB_NAME => find_run.JOB_NAME );


programs_log.kill#( schema=> 'www_server', aditional_info=>'FIND_USERS', task_id => kill_task.task_id);

4	19	WWW_SERVER	FIND_USERS_JOB	JOB	job поиск 	FIND_USERS			RUN	01.09.2021 14:46:32	
4	19	WWW_SERVER	FIND_USERS.FIND	PROGRAM		FIND_USERS	960643		RUN	01.09.2021 14:46:33	
