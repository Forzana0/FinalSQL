create Database BkSp09

use BkSp09

create table authors (
    id int identity(1,1) primary key,
    name nvarchar(max) not null,
    surname nvarchar(max) not null,
    countryid int not null foreign key references countries(id)
);

create table books (
    id int identity(1,1) primary key,
    name nvarchar(max) not null,
    pages int not null check (pages > 0),
    price money not null check (price >= 0),
    publishdate date not null check (publishdate <= getdate()),
    authorid int not null foreign key references authors(id),
    themeid int not null foreign key references themes(id)
);

create table countries (
    id int identity(1,1) primary key,
    name nvarchar(50) not null unique
);

create table sales (
    id int identity(1,1) primary key,
    price money not null check (price >= 0),
    quantity int not null check (quantity > 0),
    saledate date not null default getdate(),
    bookid int not null foreign key references books(id),
    shopid int not null foreign key references shops(id)
);

create table shops (
    id int identity(1,1) primary key,
    name nvarchar(max) not null,
    countryid int not null foreign key references countries(id)
);

create table themes (
    id int identity(1,1) primary key,
    name nvarchar(100) not null unique
);

insert into countries (name) values
('Ukraine'),
('Russia'),
('USA'),
('UK'),
('Germany'),
('France');

insert into authors (name, surname, countryid) values
('Stephen', 'King', 3),
('Agatha', 'Christie', 4),
('Arthur', 'Conan Doyle', 4),
('J.K.', 'Rowling', 4),
('Dan', 'Brown', 3),
('J.R.R.', 'Tolkien', 5),
('Leo', 'Tolstoy', 2),
('Jane', 'Austen', 4),
('Fyodor', 'Dostoevsky', 2),
('Mark', 'Twain', 3);

insert into themes (name) values
('Fiction'),
('Mystery'),
('Thriller'),
('Fantasy'),
('Science Fiction'),
('Romance'),
('Horror'),
('Adventure'),
('Biography'),
('Self-Help');

insert into shops (name, countryid) values
('BookEmporium', 3),
('ReadersCorner', 4),
('BookWorld', 1),
('LiteraryHaven', 5),
('NovelNest', 2),
('PageTurner', 3),
('BookwormBoutique', 4);

insert into books (name, pages, price, publishdate, authorid, themeid) values
('The Shining', 450, 15.99, '1977-01-28', 1, 7),
('Murder on the Orient Express', 256, 12.50, '1934-01-01', 2, 2),
('The Adventures of Sherlock Holmes', 307, 9.99, '1892-10-14', 3, 2),
('Harry Potter and the Philosopher''s Stone', 332, 19.99, '1997-06-26', 4, 4),
('The Da Vinci Code', 454, 18.95, '2003-03-18', 5, 8),
('The Hobbit', 310, 14.50, '1937-09-21', 6, 4),
('War and Peace Microsoft', 1225, 24.99, '1869-01-01', 7, 1),
('Pride and Prejudice', 279, 8.99, '1813-01-28', 8, 6),
('Crime and Punishment', 551, 11.75, '1866-01-01', 9, 2),
('Adventures of Huckleberry Finn', 366, 10.25, '1884-12-10', 10, 7);

insert into sales (price, quantity, bookid, shopid) values
(15.99, 40, 1, 1),
(12.50, 15, 2, 2),
(9.99, 25, 3, 3),
(19.99, 30, 4, 4),
(18.95, 18, 5, 5),
(14.50, 22, 6, 6),
(24.99, 10, 7, 7),
(8.99, 28, 8, 1),
(11.75, 17, 9, 2),
(10.25, 21, 10, 3);

-- 1
select * from books where pages > 500 and pages < 650;

-- 2
select * from books where left(name, 1) = 'A' or left(name, 1) = 'Z';

-- 3
select b.* from books b
inner join sales s on b.id = s.bookid
where b.themeid = (select id from themes where name = 'Detective') and s.quantity > 30;

-- 4
select * from books where name like '%Microsoft%' and name not like '%Windows%';

-- 5
select b.name, t.name as theme, concat(a.name, ' ', a.surname) as author_full_name from books b
inner join authors a on b.authorid = a.id
inner join themes t on b.themeid = t.id
where b.price / b.pages < 0.65;

-- 6
select * from books where len(name) - len(replace(name, ' ', '')) = 3;

-- 7
select b.name as book_name, t.name as theme, concat(a.name, ' ', a.surname) as author, s.price, s.quantity, sh.name as shop_name from sales s
inner join books b on s.bookid = b.id
inner join themes t on b.themeid = t.id
inner join authors a on b.authorid = a.id
inner join shops sh on s.shopid = sh.id
where b.name not like '%A%' and t.name <> 'Programming' and concat(a.name, ' ', a.surname) <> 'Herbert Schildt' and s.price between 10 and 20
and s.quantity >= 8 and sh.countryid not in (select id from countries where name in ('Ukraine', 'Russia'));

-- 8
select 'Number of authors', count(*) from authors
union all
select 'Number of books', count(*) from books
union all
select 'Average sales price', avg(price) from sales
union all
select 'Average page count', avg(pages) from books;

-- 9
select t.name as theme, sum(b.pages) as total_pages from books b
inner join themes t on b.themeid = t.id
group by t.name;

-- 10
select concat(a.name, ' ', a.surname) as author, count(*) as num_books, sum(b.pages) as total_pages from books b
inner join authors a on b.authorid = a.id
group by concat(a.name, ' ', a.surname);

-- 11
select top 1 * from books where themeid = (select id from themes where name = 'Programming') order by pages desc;

-- 12
select t.name as theme, avg(b.pages) as avg_pages from books b
inner join themes t on b.themeid = t.id
group by t.name
having avg(b.pages) <= 400;

-- 13
select t.name as theme, sum(b.pages) as total_pages from books b
inner join themes t on b.themeid = t.id
where b.pages > 400 and t.name in ('Programming', 'Administration', 'Design')
group by t.name;

-- 14
select b.name as book_name, sh.name as shop_name, concat(a.name, ' ', a.surname) as sold_by, s.saledate, s.quantity from sales s
inner join books b on s.bookid = b.id
inner join shops sh on s.shopid = sh.id
inner join authors a on b.authorid = a.id;

-- 15
select top 1 sh.name as most_profitable_store, sum(s.price * s.quantity) as total_revenue from sales s
inner join shops sh on s.shopid = sh.id
group by sh.name
order by total_revenue desc;
