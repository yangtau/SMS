create table users (
    id VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    updateTime DATETIME NOT NULL,
    PRIMARY KEY(id)
) engine=InnoDB default charset=utf8mb4;

create table students (
    id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phonenumber VARCHAR(20),
    PRIMARY KEY(id)
) engine=InnoDB default charset=utf8mb4;