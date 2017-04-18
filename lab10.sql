
create or replace function PreReqsFor(int, REFCURSOR) returns refcursor as 
$$
declare
  --
  courseNumQ int       := $1;
  resultset   REFCURSOR := $2;
begin
   open resultSet for
      select preReqNum 
      from Prerequisites
      where courseNum = courseNumQ;
   return resultSet;
end;
$$ language plpgsql

create or replace function IsPreReqFor(int, REFCURSOR) returns refcursor as
$$
declare
  --
  preReqNumQ int       := $1;
  resultset  REFCURSOR := $2;
begin
   open resultSet for
      select courseNum 
      from Prerequisites
      where preReqNum = preReqNumQ;
   return resultSet;
end;
$$ language plpgsql
