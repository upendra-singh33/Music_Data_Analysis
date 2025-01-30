select * from album
/* Q.1 : who is the senior most employee based on job title? */

select * from employee
order by levels desc
limit 1




/* Q.2 : which countries have the most invoices? */

select count(*) as total_invoice, billing_country from invoice
group by billing_country
order by total_invoice desc
limit 1




-- Q.3: What are the top 3 values of total invoice

Select invoice_id, billing_country, total from invoice
order by total desc
limit 3




/* Q.4: Which city has the best customer? We would like to 
--throw a promotional music festival in the city we made the most money.
--write a query that returns one city that has the highest sum of invoice 
--totals.Returns both the city name & sum of all invoice totals. */

select * from invoice
select sum(total) as total_invoice, billing_city from invoice
group by billing_city
order by total_invoice desc
limit 1





/*Q.5: who is the best customer? The customer who has spent the most 
--money will be declared the best customer. Write a query that returns the 
--person who has spent the most money. */

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as Total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by Total desc
limit 5







/*QUESTION SET 2

--Q.1 write a query to return the email, first name, last name., & genre of all rock music listners. 
--return your list ordered alphabetically by email starting with A.*/

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
		select track_id from track
		join genre on track.genre_id = genre.genre_id
		where genre.name like 'Rock'
)
order by email asc;

select * from genre
select * from track
select * from invoice_line




/* Q.2 let's invite the artist who have writen the most rock music in our dataset. 
write a query that returns the artist name and total track count on the top 10 rock bands */

SELECT artist.artist_id, artist.name, count(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id 
order by number_of_songs desc
limit 10;






/*Q.3 Return all the track names that have a song length longer then the average song lenth.
--Return the name and milliseconds for each track. order by the song length with the longer song listed first.
select * from track*/

select name, milliseconds
from track
where milliseconds >(
		select avg(milliseconds) as avg_track_length
		from track)
order by milliseconds desc








/*Question set 3

--Q.1 find how much amount spent by each customers on artist? write a query to return 
--customer name, artist name and total spent.n*/

with best_selling_artist as (
		SELECT artist.artist_id AS artist_id, artist.name as artist_name, 
		sum(invoice_line.unit_price*invoice_line.quantity) AS total_sales
		FROM invoice_line
		join track on track.track_id = invoice_line.track_id
		join album on album.album_id = track.album_id
		join artist on artist.artist_id = album.artist_id
		group by 1
		order by total_sales desc
		limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.album_id
group by 1,2,3,4
order by 5 desc;







/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1






/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1



