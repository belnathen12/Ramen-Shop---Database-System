--No.1 
SELECT DISTINCT R.RamenId, RamenName, CONVERT(VARCHAR(100), COUNT(RD.IngId)) + ' Ingredients' AS 'Total Ingredients'
FROM Ramen R, Ingredient I, RecipeDetail RD
WHERE R.RamenId = RD.RamenId AND RD.IngId = I.IngId AND I.IngStock < 25 
GROUP BY R.RamenId, R.RamenName 
HAVING COUNT(RD.IngId) > 1
--2
SELECT COUNT(ST.SalesId) AS 'Number of Sales', C.CustomerName, SUBSTRING(C.CustomerGender,1,1) AS 'Gender',S.StaffName
FROM SalesTransaction ST, Customer C, Staff S
WHERE C.CustomerId = ST.CustomerId AND S.StaffId = ST.StaffId AND S.StaffGender = 'Female' AND ABS(DATEDIFF(YEAR,S.StaffDOB,C.CustomerDOB)) > 5
GROUP BY C.CustomerName, S.StaffName, C.CustomerGender

--3
SELECT FORMAT(PT.PurchaseDate,'dd/MM/yyyy') AS 'Purchase Date',S.StaffName,SP.SupplierName,COUNT(PTD.IngId) AS 'Total Ingredient',SUM(PTD.Qty) AS 'Total Quantity'
from Staff S,Supplier SP,PurchaseTransactionDetail PTD,PurchaseTransaction PT
WHERE S.StaffId = PT.StaffId AND SP.SupplierId = PT.SupplierId AND PT.PurchaseId = PTD.PurchaseId AND  YEAR(PurchaseDate) = 2016 AND LEN(SP.SupplierName) < 15
GROUP BY PT.PurchaseDate,S.StaffName,SP.SupplierName

--4
SELECT C.CustomerName,C.CustomerPhone,DATENAME(WEEKDAY,ST.SalesDate) AS 'Sales Day',COUNT(STD.SalesId) AS 'Variant Ramen Sold'
FROM Customer C,SalesTransaction ST,SalesTransactionDetail STD
WHERE C.CustomerId = ST.CustomerId AND ST.SalesId = STD.SalesId AND MONTH(ST.SalesDate) = 03
GROUP BY C.CustomerName,C.CustomerPhone,ST.SalesDate
HAVING SUM(STD.Qty) > 0


--No.5 
SELECT P.PurchaseId, I.IngName, PD.Qty, S.StaffName, STUFF(S.StaffPhone, 1, 1, '+62') AS 'Staff Phone'
FROM PurchaseTransaction P, PurchaseTransactionDetail PD, Staff S, Ingredient I
WHERE P.PurchaseId = PD.PurchaseId AND S.StaffId = P.StaffId AND PD.IngId = I.IngId 
AND YEAR(P.PurchaseDate) = 2017 AND StaffSalary > (SELECT AVG(StaffSalary) FROM Staff)
 


--No.6
SELECT DISTINCT STUFF(S.StaffId, 1, 2, 'Staff ') AS 'Staff ID', StaffName, FORMAT (SalesDate , 'MMM dd yyyy') as 'Sales Date', (SELECT SUM(Qty) FROM SalesTransactionDetail SL2 WHERE SL1.SalesId = SL2.SalesId ) AS Quantity     
FROM Staff S, SalesTransaction ST, SalesTransactionDetail SL1
WHERE 
S.StaffId = ST.StaffId AND ST.SalesId = SL1.SalesId AND 
(LEN(S.StaffName + ';')-LEN(REPLACE(S.StaffName,' ','')) - 1) >= 2 AND StaffSalary < (SELECT AVG(StaffSalary) FROM Staff)

--No.7

WITH SalesQuantity (SalesId, Quantity)
AS
(
	SELECT DISTINCT SL1.SalesId, (SELECT SUM(Qty) FROM SalesTransactionDetail SL2 WHERE SL1.SalesId = SL2.SalesId ) AS Quantity     
	FROM SalesTransaction ST, SalesTransactionDetail SL1
	WHERE ST.SalesId = SL1.SalesId
)
SELECT DISTINCT COUNT(SLD.RamenId) AS 'Total Ramen Sold', 
				SUBSTRING(CustomerName, (LEN(CustomerName)-(CHARINDEX(' ',REVERSE(CustomerName))) + 2), LEN(CustomerName) - (LEN(CustomerName)-CHARINDEX(' ',REVERSE(CustomerName))) + 2) AS 'Customer Last Name',
				StaffName, SalesDate
FROM SalesQuantity, SalesTransactionDetail SLD, SalesTransaction SL1, Customer C, Staff S
WHERE SL1.SalesId = SLD.SalesId AND SL1.SalesId = SalesQuantity .SalesId AND SL1.CustomerId = C.CustomerId AND S.StaffId = SL1.StaffId
AND Quantity < (SELECT AVG(Quantity) FROM SalesQuantity)
GROUP BY SL1.SalesId, CustomerName,  StaffName, SalesDate, Quantity
HAVING LEN(CustomerName) > 15

/*Kalau maksud no.7 minta Total Ramen Sold = Total quantity ramen yang dijual setiap sales maka pakenya query ini:
WITH SalesQuantity (SalesId, Quantity)
AS
(
	SELECT DISTINCT SL1.SalesId, (SELECT SUM(Qty) FROM SalesTransactionDetail SL2 WHERE SL1.SalesId = SL2.SalesId ) AS Quantity     
	FROM SalesTransaction ST, SalesTransactionDetail SL1
	WHERE ST.SalesId = SL1.SalesId
)
SELECT DISTINCT Quantity AS 'Total Ramen Sold', 
				SUBSTRING(CustomerName, (LEN(CustomerName)-(CHARINDEX(' ',REVERSE(CustomerName))) + 2), LEN(CustomerName) - (LEN(CustomerName)-CHARINDEX(' ',REVERSE(CustomerName))) + 2) AS 'Customer Last Name',
				StaffName, SalesDate
FROM SalesQuantity, SalesTransactionDetail SLD, SalesTransaction SL1, Customer C, Staff S
WHERE SL1.SalesId = SLD.SalesId AND SL1.SalesId = SalesQuantity .SalesId AND SL1.CustomerId = C.CustomerId AND S.StaffId = SL1.StaffId
AND Quantity < (SELECT AVG(Quantity) FROM SalesQuantity)
GROUP BY SL1.SalesId, CustomerName,  StaffName, SalesDate, Quantity
HAVING LEN(CustomerName) > 15
*/

--No.8
--Kalau Sesuain soal aja pake sum
SELECT SL.SalesId, CustomerName, SUBSTRING(CustomerGender, 1, 1) AS Gender, R.RamenName,CONVERT(VARCHAR(100), SUM(R.Price)) + ' IDR' AS 'Total Price' 
FROM SalesTransaction SL, SalesTransactionDetail SLD, Customer C, Ramen R
WHERE SL.CustomerId = C.CustomerId AND SLD.RamenId = R.RamenId AND SL.SalesId = SLD.SalesId 
AND R.Price  > (SELECT MIN(Ramen.Price) FROM Ramen) --AND ABS(DATEDIFF(YEAR, GETDATE(), CustomerDOB)) < 17
GROUP BY SL.SalesId, CustomerName, CustomerGender , R.RamenName

--Kalau total price yang dimaksud itu total price ramen jenis tertentu setiap satu sales maka pake ini:
/*SELECT SL.SalesId, CustomerName, SUBSTRING(CustomerGender, 1, 1) AS Gender, R.RamenName,CONVERT(VARCHAR(100), (SLD.Qty *  R.Price)) + ' IDR' AS 'Total Price' 
FROM SalesTransaction SL, SalesTransactionDetail SLD, Customer C, Ramen R
WHERE SL.CustomerId = C.CustomerId AND SLD.RamenId = R.RamenId AND SL.SalesId = SLD.SalesId 
AND R.Price  > (SELECT MIN(Ramen.Price) FROM Ramen) AND ABS(DATEDIFF(YEAR, GETDATE(), CustomerDOB)) < 17*/
--No.9 
GO
CREATE VIEW ViewSales AS
SELECT CustomerName, COUNT(SL.SalesID) AS 'Number of Sales', (SLD.Qty *  SUM(R.Price)) AS 'Total Price'
FROM Customer C, SalesTransaction SL, Ramen R, SalesTransactionDetail SLD
WHERE SL.CustomerId = C.CustomerId AND SLD.RamenId = R.RamenId AND SL.SalesId = SLD.SalesId 
AND YEAR(SalesDate) < 2017 AND CustomerAddress LIKE 'Pasar %'
GROUP BY CustomerName, SL.SalesId, SLD.Qty 
--No.10
GO
CREATE VIEW PurchaseDetail AS
SELECT CONVERT(VARCHAR(100), SUM(Qty)) + ' Pcs' AS 'Number of Item Purchased', COUNT(PD.PurchaseId) AS 'Number of Transaction', S.StaffName, SP.SupplierName 
FROM PurchaseTransaction P, PurchaseTransactionDetail PD, Supplier SP, Staff S
WHERE P.PurchaseId = PD.PurchaseId AND P.StaffId = S.StaffId  AND P.SupplierId = SP.SupplierId 
AND YEAR(PurchaseDate) = 2016 AND StaffGender = 'Male'
GROUP BY StaffName, SupplierName, PD.PurchaseId



