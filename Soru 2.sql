CREATE PROCEDURE CheckProductStock
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT StockQuantity
    FROM Products
    WHERE ProductId = @ProductId;
END;

CREATE PROCEDURE DecreaseProductStock
    @ProductId INT,
    @QuantitySold INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Önce yeterli stok var mý kontrol edelim
    IF EXISTS (
        SELECT 1
        FROM Products
        WHERE ProductId = @ProductId AND StockQuantity >= @QuantitySold
    )
    BEGIN
        UPDATE Products
        SET StockQuantity = StockQuantity - @QuantitySold
        WHERE ProductId = @ProductId;
    END
    ELSE
    BEGIN
        RAISERROR('Yeterli stok yok.', 16, 1);
    END
END;

CREATE PROCEDURE NotifyOrderCreated
    @OrderId INT,
    @UserId INT,
    @Message NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notifications (UserId, OrderId, Message, CreatedAt)
    VALUES (@UserId, @OrderId, @Message, GETDATE());
END;
