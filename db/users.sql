create table users (
    id VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    createTime DATETIME NOT NULL,
    PRIMARY KEY(id)
) engine=InnoDB default charset=utf8;