
create table gifs (
  id varchar primary key not null,
  file_name varchar not null
);

create table tags (
  tag varchar not null,
  gif_id varchar not null,
  foreign key (gif_id) references gifs (id)
);

