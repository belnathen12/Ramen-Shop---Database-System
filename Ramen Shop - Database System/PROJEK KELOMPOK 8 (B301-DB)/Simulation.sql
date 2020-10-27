--Simulation

--Simulasi ketika ada transaksi purchase ingredient
CREATE PROCEDURE SimulatePurchaseTransaction 
	@TypesOfIngredient INT,
	@PurchaseId CHAR(5),
	@StaffId CHAR(5),
	@SupplierId CHAR(5), 
	@PurchaseDate DATE,
	@IngId VARCHAR(100),
	@Qty VARCHAR(100)

AS
	BEGIN
		INSERT INTO PurchaseTransaction(PurchaseId, StaffId, SupplierId , PurchaseDate) 
		VALUES(@PurchaseId, @StaffId, @SupplierId, @PurchaseDate )

		DECLARE @FLAG INT = 0
		--Loop untuk insert ke TransactionDetail dan Ingredient sebanyak jenis ingredient yang dibeli
		WHILE (@FLAG < @TypesOfIngredient)
			BEGIN
				--Variabel untuk IngId yang sedang akan dimasukkan dan jumlahnya
				DECLARE @CurIngId CHAR(5) =  (SELECT TRIM(PARSENAME(REPLACE(@IngId,',','.'), @TypesOfIngredient-@FLAG ))) 
				DECLARE @CurIngQty Int = (SELECT CAST(TRIM(PARSENAME( REPLACE(@Qty,',','.'), @TypesOfIngredient-@FLAG )) AS INT))
				--insert ke dalam tabel PurchaseTransactionDetail
				INSERT INTO PurchaseTransactionDetail(PurchaseId, IngId, Qty)
				VALUES(@PurchaseId, @CurIngId, @CurIngQty)
				--Update Stock ingredient yang dibeli
				UPDATE Ingredient 
				SET IngStock = IngStock  + @CurIngQty
				WHERE IngId = @CurIngId
				SET @FLAG = @FLAG + 1
			END
	END
GO
--Ketika Execute: Types of Ingredient adalah berapa banyak ingredient yang dibeli dalam satu purchase, lalu @IngId dan @Qty adalah Id Ingredient yang dibeli dan quantitynya

/*Contoh -> */ EXEC SimulatePurchaseTransaction @PurchaseId = 'PU016', @StaffId = 'ST001', @SupplierId = 'SP001', @PurchaseDate = '2016-01-06', @IngId = 'RI001, RI002, RI003', @Qty = '1, 3, 5', @TypesOfIngredient = 3 

--Hasil dari transaksi dapat dilihat dengan select
Select * From Ingredient
Select * From PurchaseTransaction 
Select * From PurchaseTransactionDetail  
GO


-- Simulasi untuk transaksi Sales ramen
CREATE PROCEDURE SimulateSalesTransaction 
	@TypesOfRamen INT,
	@SalesId CHAR(5),
	@StaffId CHAR(5),
	@CustomerId CHAR(5), 
	@SalesDate DATE,
	@RamenId VARCHAR(100),
	@Qty VARCHAR(100)

AS
	BEGIN
		--Insert ke dalam tabel SalesTransaction
		INSERT INTO SalesTransaction(SalesId, CustomerId, StaffId, SalesDate)
		VALUES(@SalesId, @CustomerId, @StaffId, @SalesDate)
		--Loop untuk masukkan setiap Jenis Ramen yang dipesan dalam sekali transaksi 
		DECLARE @FLAG INT = 0
		WHILE (@FLAG < @TypesOfRamen )
			BEGIN
				DECLARE @CurRamenId CHAR(5) = (SELECT TRIM(PARSENAME(REPLACE(@RamenId,',','.'), @TypesOfRamen -@FLAG )))
				DECLARE @CurRamenQty Int = (SELECT CAST(TRIM(PARSENAME( REPLACE(@Qty,',','.'), @TypesOfRamen-@FLAG )) AS INT))
				
				--insert ke dalam tabel PurchaseTransactionDetail
				INSERT INTO SalesTransactionDetail(SalesId , RamenId , Qty)
				VALUES(@SalesId , @CurRamenId, @CurRamenQty)
				
				--Check berapa ingredient yang dipakai dalam satu ramen -> berapa ingredient yang akan diupdate
				
				DECLARE @RamenIngredientUsed INT
				SET @RamenIngredientUsed = (SELECT COUNT(IngId) FROM RecipeDetail WHERE RamenId = @CurRamenId )

				--Update masing-masing ingredient yang digunakan oleh satu jenis ramen
				DECLARE @IngFlag INT = 0
				WHILE(@IngFlag < @RamenIngredientUsed)
					BEGIN
						DECLARE @CurIngId CHAR(5) --IdIngredient yang sedang dicheck
						DECLARE @IngredientUsed INT --Jumlah Ingredient yang dipakai
						--CTE buat Ingredient apa saja yang dipake ramen itu
						SET @CurIngId = (
						SELECT IngId 
						FROM(
								SELECT ROW_NUMBER() OVER (ORDER BY IngId) AS RowNumber, IngId
								FROM RecipeDetail
								WHERE RamenId  = @CurRamenId  ) AS RamenIngredient	
                        WHERE RowNumber = @IngFlag  + 1)
						SET @IngredientUsed = (SELECT IngQty FROM RecipeDetail WHERE IngId = @CurIngId AND RamenId = @CurRamenId) 
						SET @IngredientUsed = @IngredientUsed * @CurRamenQty
						--Update Ingredient Table
						UPDATE Ingredient 
						SET IngStock = IngStock  - @IngredientUsed
						WHERE IngId = @CurIngId 
						SET @IngFlag  = @IngFlag + 1
					END
				SET @FLAG = @FLAG + 1
			END
	END
GO
--Simulasi SalesTransaction dengan execute procedure SimulateSalesTransaction
EXEC SimulateSalesTransaction @TypesOfRamen = 2, @SalesId = 'SL016', @StaffId = 'ST001', @CustomerId = 'CU001', @SalesDate = '2016-01-06', @RamenId = 'RA001, RA002', @Qty = '2, 4'

SELECT * FROM Ingredient 
SELECT * FROM SalesTransaction 
SELECT * FROM SalesTransactionDetail  

