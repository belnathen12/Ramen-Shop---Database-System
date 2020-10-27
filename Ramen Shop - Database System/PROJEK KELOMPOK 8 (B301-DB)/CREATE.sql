CREATE TABLE Customer(
CustomerId CHAR(5) NOT NULL PRIMARY KEY,
CustomerName VARCHAR(150) NOT NULL,
CustomerDOB Date NOT NULL,
CustomerGender VARCHAR(6) NOT NULL,
CustomerAddress VARCHAR(100) NOT NULL,
CustomerPhone CHAR(12) NOT NULL,
CONSTRAINT C1 CHECK (CustomerId LIKE 'CU[0-9][0-9][0-9]'),
CONSTRAINT C2 CHECK (CustomerAddress LIKE '%Street'),
CONSTRAINT C3 CHECK (CustomerGender = 'Male' OR CustomerGender = 'Female')
)

CREATE TABLE Staff(
StaffId CHAR(5) NOT NULL PRIMARY KEY,
StaffName VARCHAR(150) NOT NULL,
StaffDOB Date NOT NULL,
StaffGender VARCHAR(6) NOT NULL,
StaffAddress VARCHAR(100) NOT NULL,
StaffPhone CHAR(12) NOT NULL,
StaffSalary INT NOT NULL,
CONSTRAINT S1 CHECK (StaffId LIKE 'ST[0-9][0-9][0-9]'),
CONSTRAINT S2 CHECK (StaffAddress LIKE '%Street'),
CONSTRAINT S3 CHECK (StaffGender = 'Male' OR StaffGender = 'Female'),
CONSTRAINT S4 CHECK (StaffSalary BETWEEN 1500000 AND 3500000)
)

CREATE TABLE Supplier(
SupplierId CHAR(5) NOT NULL PRIMARY KEY,
SupplierName VARCHAR(150) NOT NULL,
SupplierAddress VARCHAR(100) NOT NULL,
SupplierPhone CHAR(12) NOT NULL,
CONSTRAINT SU1 CHECK (SupplierId LIKE 'SP[0-9][0-9][0-9]'),
CONSTRAINT SU2 CHECK (SupplierAddress LIKE '%Street'),
CONSTRAINT SU3 CHECK (LEN(SupplierName) BETWEEN  5 AND 50)
)

CREATE TABLE Ramen(
RamenId CHAR(5) NOT NULL PRIMARY KEY,
RamenName VARCHAR(150) NOT NULL,
Price INT NOT NULL,
CONSTRAINT R1 CHECK (RamenId LIKE 'RA[0-9][0-9][0-9]'),
CONSTRAINT R2 CHECK (RamenName LIKE '% %')
)

CREATE TABLE Ingredient(
IngId CHAR(5) NOT NULL PRIMARY KEY,
IngName VARCHAR(150) NOT NULL,
IngStock INT NOT NULL,
CONSTRAINT I1 CHECK (IngId LIKE 'RI[0-9][0-9][0-9]')
)

CREATE TABLE RecipeDetail(
RamenId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Ramen(RamenId) ON UPDATE CASCADE ON DELETE CASCADE,
IngId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Ingredient(IngId) ON UPDATE CASCADE ON DELETE CASCADE,
IngQty INT NOT NULL
CONSTRAINT PK_RecipeDetail PRIMARY KEY(RamenId, IngId)
)

CREATE TABLE SalesTransaction(
SalesId CHAR(5) NOT NULL PRIMARY KEY,
CustomerId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Customer(CustomerId) ON UPDATE CASCADE ON DELETE CASCADE,
StaffId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Staff(StaffId) ON UPDATE CASCADE ON DELETE CASCADE,
SalesDate DATE,
CONSTRAINT ST1 CHECK (SalesId LIKE 'SL[0-9][0-9][0-9]')
)

CREATE TABLE SalesTransactionDetail(
SalesId CHAR(5) NOT NULL FOREIGN KEY REFERENCES SalesTransaction(SalesId) ON UPDATE CASCADE ON DELETE CASCADE,
RamenId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Ramen(RamenId) ON UPDATE CASCADE ON DELETE CASCADE,
Qty INT NOT NULL,
CONSTRAINT PK_SalesTransactionDetail PRIMARY KEY(SalesId, RamenId)
)

CREATE TABLE PurchaseTransaction(
PurchaseId CHAR(5) NOT NULL PRIMARY KEY,
StaffId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Staff(StaffId) ON UPDATE CASCADE ON DELETE CASCADE,
SupplierId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Supplier(SupplierId) ON UPDATE CASCADE ON DELETE CASCADE,
PurchaseDate DATE,
CONSTRAINT PT1 CHECK (PurchaseId LIKE 'PU[0-9][0-9][0-9]')
)

CREATE TABLE PurchaseTransactionDetail(
PurchaseId CHAR(5) NOT NULL FOREIGN KEY REFERENCES PurchaseTransaction(PurchaseId) ON UPDATE CASCADE ON DELETE CASCADE,
IngId CHAR(5) NOT NULL FOREIGN KEY REFERENCES Ingredient(IngId) ON UPDATE CASCADE ON DELETE CASCADE,
Qty INT NOT NULL,
CONSTRAINT PK_PurchaseTransactionDetail PRIMARY KEY(PurchaseId, IngId)
)





