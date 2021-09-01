create or replace package programs_log is
----Пакет для логирования выполнения заданий job и программ,отмена их выполнения
----Сначала добавляем лог задания,в нем нет task_id, при вызове функции add# ОБЯЗАТЕЛЬНО передать параметр JOB_NAME => через имя параметра, функция перегружена
----затем добавляем лог первой программы где фигурирует task_id, sid у них будет одинаковым,по нему в дальнейшем и будет сопоставляться job
----Данный пакет только ведет журнал, саму отмену сессий выполняет job из-под SYSTEM (пакет SESSION_CONTROL)
-- Данный пакет создается в другой схеме,например WWW_SERVER
  procedure add#( SCHEMA IN VARCHAR2
                , PROGRAM_NAME IN VARCHAR2
                , INFO IN VARCHAR2  default null
                , TASK_ID IN NUMBER default null
                , SID IN NUMBER default null
                , SERIAL# IN NUMBER default null
                , INSTANCE IN NUMBER default null
                , ADITIONAL_INFO IN VARCHAR2 default null);
  procedure add#( SCHEMA IN VARCHAR2
                , JOB_NAME IN VARCHAR2
                , INFO IN VARCHAR2  default null
                , TASK_ID IN NUMBER default null
                , SID IN NUMBER default null
                , SERIAL# IN NUMBER default null
                , INSTANCE IN NUMBER default null
                , ADITIONAL_INFO IN VARCHAR2 default null);
                
  procedure delete#( SCHEMA IN VARCHAR2, PROGRAM_NAME IN VARCHAR2);
  procedure delete#( SCHEMA IN VARCHAR2, JOB_NAME IN VARCHAR2);
  procedure kill#( SCHEMA IN VARCHAR2, JOB_NAME IN VARCHAR2);
  procedure kill#( SCHEMA IN VARCHAR2, ADITIONAL_INFO in varchar2, TASK_ID in number);
  procedure kill#( SCHEMA IN VARCHAR2, PROGRAM_NAME IN VARCHAR2, SID in number default null);
  
  procedure elapse_time_start;
  function elapse_time_get(m_elapse_time_start in PLS_INTEGER default null) return number;
  function elapse_time_get_last return number;
end programs_log; 
