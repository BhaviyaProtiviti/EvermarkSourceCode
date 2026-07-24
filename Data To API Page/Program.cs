using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Transactions;
using Microsoft.Data.SqlClient;

class Program
{
    static void Main(string[] args)
    {
        ;
        if (args.Length == 0)
        {
            Console.WriteLine("Specify job type: items | trade");
            string input = Console.ReadLine()?.Trim().ToLower() ?? "";
            if (!new HashSet<string> { "items", "trade", "testitems", "testtrade", "devitems", "devtrade" }.Contains(input))
            {
                Console.WriteLine("Invalid job type. Use 'items' or 'trade'.");
                return;
            }
            Console.WriteLine("Specify auth type: basic | azure");
            string authInput = Console.ReadLine()?.Trim().ToLower() ?? "";
            if (!new HashSet<string> { "basic", "azure" }.Contains(authInput))
            {
                Console.WriteLine("Invalid auth type. Use 'basic' or 'azure'.");
                return;
            }
            args = new string[] { input, authInput };
        }
        string jobType = args[0];
        //set default auth type
        AuthType authType = AuthType.Basic;
        switch (args[1])
        {
            case "basic":
                authType = AuthType.Basic;
                break;
            case "azure":
                authType = AuthType.Azure;
                break;
        }
        DataSyncConfig config = DataSyncFactory.GetConfig(args[0]);
        if (SecureCredentialStorage.StoredValuesExist())
        {
            BusinessCentralDataIntegration.Run(config, authType).Wait();
        }
        else
        {
            SecureCredentialStorage.Run();
            BusinessCentralDataIntegration.Run(config, authType).Wait();
        }

    }
}

class SecureCredentialStorage
{
    public static void Run()
    {
        Console.Write("Enter SQL Item Connection String: ");
        string connectionString = ReadSensitiveInput();

        Console.Write("Enter SQL Trade Connection String: ");
        string connectionStringTrade = ReadSensitiveInput();


        Console.Write("Enter Business Central Username: ");
        string userNameToken = ReadSensitiveInput();

        Console.Write("Enter Business Central Access Token: ");
        string accessToken = ReadSensitiveInput();

        if (connectionString != null && connectionString != string.Empty)
            StoreSecureCredential("sql_connection.dat", connectionString);
        if (connectionStringTrade != null && connectionStringTrade != string.Empty)
            StoreSecureCredential("sql_connection_trade.dat", connectionStringTrade);
        if (accessToken != null && accessToken != string.Empty)
            StoreSecureCredential("bc_token.dat", accessToken);
        if (userNameToken != null && userNameToken != string.Empty)
            StoreSecureCredential("username.dat", userNameToken);
    }

    public static void StoreSecureCredential(string filePath, string sensitiveData)
    {
        try
        {
            byte[] encryptedData = ProtectedData.Protect(
                Encoding.UTF8.GetBytes(sensitiveData),
                null,
                DataProtectionScope.CurrentUser
            );

            File.WriteAllBytes(filePath, encryptedData);
            Console.WriteLine($"Credentials securely stored at {filePath}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error storing credentials: {ex.Message}");
        }
    }

    public static string RetrieveSecureCredential(string filePath)
    {
        try
        {
            if (!File.Exists(filePath))
                throw new FileNotFoundException("Credential file not found", filePath);

            byte[] encryptedData = File.ReadAllBytes(filePath);
            byte[] decryptedData = ProtectedData.Unprotect(
                encryptedData,
                null,
                DataProtectionScope.CurrentUser
            );

            return Encoding.UTF8.GetString(decryptedData);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error retrieving credentials: {ex.Message}");
            return string.Empty;
        }
    }

    static string ReadSensitiveInput()
    {
        StringBuilder input = new StringBuilder();
        while (true)
        {
            var key = Console.ReadKey(true);
            if (key.Key == ConsoleKey.Enter) break;
            if (key.Key == ConsoleKey.Backspace && input.Length > 0)
            {
                input.Length--;
                Console.Write("\b \b");
            }
            else if (!char.IsControl(key.KeyChar))
            {
                input.Append(@key.KeyChar);
                Console.Write("*");
            }
        }
        Console.WriteLine();
        return input.ToString();
    }

    public static bool StoredValuesExist()
    {
        return File.Exists("sql_connection.dat") && File.Exists("sql_connection_trade.dat") && File.Exists("username.dat") && File.Exists("bc_token.dat");
    }
}
public class DataSyncConfig
{
    public string SqlConnectionString { get; set; }
    public string BcTenantUrl { get; set; }
    public string BcCompanyId { get; set; }
    public string Endpoint { get; set; }
    public string Query { get; set; }

}


public enum AuthType : int
{
    Basic = 0,
    Azure = 1
}

public static class DataSyncFactory
{
    public static DataSyncConfig GetConfig(string jobType)
    {
        switch (jobType.ToLower())
        {
            case "devitems":
                return new DataSyncConfig
                {
                    SqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection.dat"),
                    BcTenantUrl = "http://sbcvenaws:7048/BC/api/tigunia/vena",
                    BcCompanyId = "3f1f22c1-90e0-ed11-9dd2-001dd8b72037",
                    Endpoint = "sbcApiVenaItems",
                    Query = @"SELECT TOP 100 * FROM [Suave_Item_Master_Summary] iSource where not exists ( select 1 from [SBC_VENA].[dbo].[Suave Brands Company, LLC$SBC Vena Item$66ff5ee3-4b26-459a-b3b6-ada562c0139d] i where i.[No_] = iSource.[No_]) order by No_;"

                };
            case "devtrade":
                return new DataSyncConfig
                {
                    SqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection_trade.dat"),
                    BcTenantUrl = "http://sbcvenaws:7048/BC/api/tigunia/vena",
                    BcCompanyId = "3f1f22c1-90e0-ed11-9dd2-001dd8b72037",
                    Endpoint = "sbcApiVenaTradeLines",
                    Query = @"SELECT TOP 100 * FROM [Fact Sales Posted Transactions] WHERE DW_Id > @LastDWId and [Posting Date] >= '11/1/2024' and [Total Trade Amount] is not null ORDER BY DW_Id;"
                };
            case "testitems":
                return new DataSyncConfig
                {
                    SqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection.dat"),
                    BcTenantUrl = "https://SBRBC01:7548/SBR_BC22_TEST/api/tigunia/vena",
                    BcCompanyId = "3f1f22c1-90e0-ed11-9dd2-001dd8b72037",
                    Endpoint = "sbcApiVenaItems",
                    Query = @"SELECT TOP 100 * FROM [Suave_Item_Master_Summary] iSource where not exists ( select 1 from [Suave_BC22_Test].[dbo].[Suave Brands Company, LLC$SBC Vena Item$66ff5ee3-4b26-459a-b3b6-ada562c0139d] i where i.[No_] = iSource.[No_]) order by No_;"


                };
            case "testtrade":
                return new DataSyncConfig
                {
                    SqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection_trade.dat"),
                    BcTenantUrl = "https://SBRBC01:7548/SBR_BC22_TEST/api/tigunia/vena",
                    BcCompanyId = "3f1f22c1-90e0-ed11-9dd2-001dd8b72037",
                    Endpoint = "sbcApiVenaTradeLines",
                    Query = @"SELECT TOP 100 * FROM [Fact Sales Posted Transactions] WHERE DW_Id > @LastDWId and [Posting Date] >= '11/1/2024' ORDER BY DW_Id;"
                };
            case "items":
                return new DataSyncConfig
                {
                    SqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection.dat"),
                    BcTenantUrl = "https://bcwebservices.suavebrandsco.com:7348/SBR_ODATA_PROD/api/tigunia/vena",
                    BcCompanyId = "3f1f22c1-90e0-ed11-9dd2-001dd8b72037",
                    Endpoint = "sbcApiVenaItems",
                    Query = @"SELECT TOP 100 * FROM [Suave_Item_Master_Summary] iSource where not exists ( select 1 from [Suave_BC22].[dbo].[Suave Brands Company, LLC$SBC Vena Item$66ff5ee3-4b26-459a-b3b6-ada562c0139d] i where i.[No_] = iSource.[No_]) order by No_;"

                };
            case "trade":
                return new DataSyncConfig
                {
                    SqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection_trade.dat"),
                    BcTenantUrl = "https://bcwebservices.suavebrandsco.com:7348/SBR_ODATA_PROD/api/tigunia/vena",
                    BcCompanyId = "3f1f22c1-90e0-ed11-9dd2-001dd8b72037",
                    Endpoint = "sbcApiVenaTradeLines",
                    Query = @"SELECT TOP 100 * FROM [Fact Sales Posted Transactions] WHERE DW_Id > @LastDWId and [Posting Date] >= '11/1/2024' ORDER BY DW_Id;"
                };
            default:
                throw new Exception("Unknown job type.");
        }
    }
}

class BusinessCentralDataIntegration
{
    private static readonly HttpClient _httpClient = new HttpClient();
    public static async Task Run(DataSyncConfig config, AuthType authType)
    {
        try
        {

            string userNameToken = SecureCredentialStorage.RetrieveSecureCredential("username.dat");
            string accessToken = SecureCredentialStorage.RetrieveSecureCredential("bc_token.dat");
            string bcTenant = config.BcTenantUrl;
            string bcCompany = "Suave Brands Company, LLC";
            string bcBatchUrl = $"{bcTenant}/v2.0/$batch";
            string bcCompanyId = config.BcCompanyId;
            string endpoint = config.Endpoint;
            string queryText = config.Query;
            //int offset = 0;
            //int batchSize = 100;


            switch (authType)
            {
                case AuthType.Basic:
                    string credentials = $"{userNameToken}:{accessToken}";
                    string base64Credentials = Convert.ToBase64String(Encoding.UTF8.GetBytes(credentials));
                    _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", base64Credentials);
                    break;
                case AuthType.Azure:
                    _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                    break;
            }


            _httpClient.DefaultRequestHeaders.Add("Accept", "application/json");

            while (true)
            {
                var records = new List<Dictionary<string, object>>();
                string sqlConnectionString = "";
                switch (endpoint)
                {
                    case "sbcApiVenaItems":
                        sqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection.dat");
                        if (string.IsNullOrWhiteSpace(sqlConnectionString) || string.IsNullOrWhiteSpace(accessToken))
                            throw new Exception("Missing credentials. Ensure they are stored correctly before running.");
                        records = GetDataFromSQL(sqlConnectionString, queryText);
                        break;
                    case "sbcApiVenaTradeLines":
                        sqlConnectionString = SecureCredentialStorage.RetrieveSecureCredential("sql_connection_trade.dat");
                        if (string.IsNullOrWhiteSpace(sqlConnectionString) || string.IsNullOrWhiteSpace(accessToken))
                            throw new Exception("Missing credentials. Ensure they are stored correctly before running.");
                        int lastDwId = File.Exists("LastTradeDWID.dat") ? Convert.ToInt32(File.ReadAllText("LastTradeDWID.dat")) : 0;
                        records = GetTradeDataFromSQL(sqlConnectionString, lastDwId, queryText);
                        break;
                }
                if (records.Count == 0)
                    break;

                string batchRequestJson = CreateBatchRequest(records, bcCompany, bcCompanyId, endpoint);
                await SendDataToBusinessCentral(batchRequestJson, bcBatchUrl, userNameToken, accessToken, _httpClient);

                //offset += batchSize;
            }

        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error in Business Central Data Integration: {ex.Message}");
        }
    }

    static List<Dictionary<string, object>> GetDataFromSQL(string connectionString, string query)
    {
        List<Dictionary<string, object>> records = new List<Dictionary<string, object>>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using SqlCommand cmd = new SqlCommand(query, conn);
                //cmd.Parameters.AddWithValue("@Offset", offset);

                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    var record = new Dictionary<string, object>
                            {
                                { "no", reader["No_"] },
                                { "description", reader["Description"] },
                                { "status", reader["Status"] },
                                { "prevStatus", reader["PrevStatus"] },
                                { "statusChanged", reader["StatusChanged"] }
                                    ,
                                { "brand", reader["Brand"] },
                                { "category", reader["Category"] },
                                { "subCategory", reader["Sub-Category"] },
                                { "unitCost", reader["Unit Cost"] },
                                { "unitPrice", reader["Unit Price"] },
                                { "edlpMSRP", reader["EDLP MSRP"] },
                                { "hLMSRP", reader["H-L MSRP"] }
                                    ,
                                { "eachUPC", reader["Each UPC"] },
                                { "caseUPC", reader["Case UPC"] },
                                { "innerPackUPC", reader["Inner Pack UPC"] },
                                { "gtin", reader["GTIN"] },
                                { "user", reader["User"] },
                                { "subBrand", reader["Sub Brand"] },
                                { "form", reader["Form"] },
                                { "size", reader["Size"] },
                                { "variant", reader["Variant"] }
                                    ,
                                { "packType", reader["Pack Type"] },
                                { "promoFamily", reader["Promo Family"] }
                                    ,
                                { "sbcCreateDate",ConvertDateTimeToBCDate(reader["SBC Create Date"]) }
                                    ,
                                { "countryRegionOfOriginCode", reader["Country_Region of Origin Code"] }
                                    ,
                                { "tariffNo", reader["Tariff No_"] },
                                { "scheduleBCode", reader["Schedule B Code"] },
                                { "osDisplay", reader["OS/Display"] },
                                { "wercsID", reader["WERCS ID"] },
                                { "regulatoryClassification", reader["Regulatory Classification"] },
                                { "minimumOrderQuantity", reader["Minimum Order Quantity"] },
                                { "brandCategory", reader["Brand Category"] }
                                    ,
                                { "country", reader["Country"] },
                                { "exportable", reader["Exportable"] },
                                { "shelfLifeDays", reader["Shelf Life (Days)"] },
                                { "hazardousMaterialCode", reader["Hazardous Material Code"] },
                                { "abcCode", reader["ABC Code"] },
                                { "runStrategy", reader["Run Strategy"] },
                                { "safetyStockDays", reader["Safety Stock Days"] },
                                { "leadTime", reader["Lead Time"] }
                                    ,
                                { "msaItem", reader["MSA Item"] },
                                { "previousItem", reader["Previous Item"] },
                                { "productionPlant1", reader["Production Plant 1"] },
                                { "productionPlant2", reader["Production Plant 2"] },
                                { "productionPlant3", reader["Production Plant 3"] },
                                { "productionLine1", reader["Production Line 1"] },
                                { "productionLine2", reader["Production Line 2"] },
                                { "ti", reader["Ti"] },
                                { "hi", reader["Hi"] },
                                { "uoMQtyICI", reader["UoM Qty ICI"] },
                                { "uoMQtyEA", reader["UoM Qty EA"] },
                                { "uoMLengthEA", reader["UoM Length EA"] },
                                { "uoMWidthEA", reader["UoM Width EA"] },
                                { "uoMHeightEA", reader["UoM Height EA"] },
                                { "uoMWeightEA", reader["UoM Weight EA"] },
                                { "uoMQtyCS", reader["UoM Qty CS"] },
                                { "uoMLengthCS", reader["UoM Length CS"] },
                                { "uoMWidthCS", reader["UoM Width CS"] },
                                { "uoMHeightCS", reader["UoM Height CS"] },
                                { "uoMWeightCS", reader["UoM Weight CS"] },
                                { "uoMCubageCS", reader["UoM Cubage CS"] },
                                { "uoMQtyLAY", reader["UoM Qty LAY"] },
                                { "uoMLengthLAY", reader["UoM Length LAY"] },
                                { "uoMWidthLAY", reader["UoM Width LAY"] },
                                { "uoMHeightLAY", reader["UoM Height LAY"] },
                                { "uoMWeightLAY", reader["UoM Weight LAY"] },
                                { "uoMQtyPAL", reader["UoM Qty PAL"] },
                                { "uoMLengthPAL", reader["UoM Length PAL"] },
                                { "uoMWidthPAL", reader["UoM Width PAL"] },
                                { "uoMHeightPAL", reader["UoM Height PAL"] },
                                { "uoMWeightPAL", reader["UoM Weight PAL"] },
                                { "uoMQtyINNER", reader["UoM Qty INNER"] },
                                { "uoMLengthINNER", reader["UoM Length INNER"] },
                                { "uoMWidthINNER", reader["UoM Width INNER"] },
                                { "uoMHeightINNER", reader["UoM Height INNER"] },
                                { "uoMWeightINNER", reader["UoM Weight INNER"] }

                            };
                    records.Add(record);
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"SQL Error: {ex.Message}");
        }

        return records;
    }
    static List<Dictionary<string, object>> GetTradeDataFromSQL(string connectionString, int lastDwId, string query)
    {
        List<Dictionary<string, object>> records = new List<Dictionary<string, object>>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using SqlCommand cmd = new SqlCommand(query, conn);
                //cmd.Parameters.AddWithValue("@Offset", offset); // Not being used anymore.
                cmd.Parameters.AddWithValue("@LastDWId", lastDwId);
                using SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {

                    var record = new Dictionary<string, object>();
                    //{

                    if (reader["DW_Id"] != DBNull.Value) record["dwId"] = reader["DW_Id"];
                    if (reader["Company Id"] != DBNull.Value) record["companyId"] = reader["Company Id"];
                    if (reader["Sales Document Id"] != DBNull.Value) record["salesDocumentId"] = reader["Sales Document Id"];
                    if (reader["Document Line Number"] != DBNull.Value) record["documentLineNumber"] = reader["Document Line Number"];
                    if (reader["Item Id"] != DBNull.Value) record["itemId"] = reader["Item Id"];

                    if (reader["Order Date"] != DBNull.Value) record["orderDate"] = ConvertDateTimeToBCFormat(reader["Order Date"]);
                    if (reader["Posting Date"] != DBNull.Value) record["postingDate"] = ConvertDateTimeToBCFormat(reader["Posting Date"]);
                    if (reader["LastDayOfMonth"] != DBNull.Value) record["lastDayOfMonth"] = ConvertDateTimeToBCFormat(reader["LastDayOfMonth"]);
                    if (reader["LastDayOfMonth_ShipmentDate"] != DBNull.Value) record["lastDayOfMonthShipmentDate"] = ConvertDateTimeToBCFormat(reader["LastDayOfMonth_ShipmentDate"]);

                    if (reader["Case Qty"] != DBNull.Value) record["caseQty"] = reader["Case Qty"];
                    if (reader["Customer Posting Group ID"] != DBNull.Value) record["customerPostingGroupID"] = reader["Customer Posting Group ID"];
                    if (reader["Sell to Customer Id"] != DBNull.Value) record["sellToCustomerId"] = reader["Sell to Customer Id"];
                    if (reader["Bill to Customer Id"] != DBNull.Value) record["billToCustomerId"] = reader["Bill to Customer Id"];
                    if (reader["Entry Number"] != DBNull.Value) record["entryNumber"] = reader["Entry Number"];
                    if (reader["Business Posting Group Id"] != DBNull.Value) record["businessPostingGroupId"] = reader["Business Posting Group Id"];
                    if (reader["Document Type Code"] != DBNull.Value) record["documentTypeCode"] = reader["Document Type Code"];
                    if (reader["Document Type"] != DBNull.Value) record["documentType"] = reader["Document Type"];
                    if (reader["Global Dimension 1 Id"] != DBNull.Value) record["globalDimension1Id"] = reader["Global Dimension 1 Id"];
                    if (reader["Global Dimension 2 Id"] != DBNull.Value) record["globalDimension2Id"] = reader["Global Dimension 2 Id"];
                    if (reader["Line Type Id"] != DBNull.Value) record["lineTypeId"] = reader["Line Type Id"];
                    if (reader["Inventory Posting Group Id"] != DBNull.Value) record["inventoryPostingGroupId"] = reader["Inventory Posting Group Id"];
                    if (reader["Location Id"] != DBNull.Value) record["locationId"] = reader["Location Id"];
                    if (reader["Ship-to Code"] != DBNull.Value) record["shipToCode"] = reader["Ship-to Code"];
                    if (reader["Emerson Ship to Code"] != DBNull.Value) record["emersonShipToCode"] = reader["Emerson Ship to Code"];
                    if (reader["Product Posting Group Id"] != DBNull.Value) record["productPostingGroupId"] = reader["Product Posting Group Id"];
                    if (reader["Salesperson Id"] != DBNull.Value) record["salespersonId"] = reader["Salesperson Id"];
                    if (reader["Quantity"] != DBNull.Value) record["quantity"] = reader["Quantity"];
                    if (reader["Quantity Shipped"] != DBNull.Value) record["quantityShipped"] = reader["Quantity Shipped"];
                    if (reader["Quantity Shipped Cases"] != DBNull.Value) record["quantityShippedCases"] = reader["Quantity Shipped Cases"];
                    if (reader["Case Weight"] != DBNull.Value) record["caseWeight"] = reader["Case Weight"];
                    if (reader["Gross Sales at Value"] != DBNull.Value) record["grossSalesAtValue"] = reader["Gross Sales at Value"];
                    if (reader["Gross Sales"] != DBNull.Value) record["grossSales"] = reader["Gross Sales"];
                    if (reader["Sales"] != DBNull.Value) record["sales"] = reader["Sales"];
                    if (reader["Discount"] != DBNull.Value) record["discount"] = reader["Discount"];
                    if (reader["Accrued Promotion"] != DBNull.Value) record["accruedPromotion"] = reader["Accrued Promotion"];
                    if (reader["Cash Discount"] != DBNull.Value) record["cashDiscount"] = reader["Cash Discount"];
                    if (reader["Cash Discount Post Exit"] != DBNull.Value) record["cashDiscountPostExit"] = reader["Cash Discount Post Exit"];
                    if (reader["Fixed Funding"] != DBNull.Value) record["fixedFunding"] = reader["Fixed Funding"];
                    if (reader["Markdowns"] != DBNull.Value) record["markdowns"] = reader["Markdowns"];
                    if (reader["National Coupon"] != DBNull.Value) record["nationalCoupon"] = reader["National Coupon"];
                    if (reader["OI Bracket"] != DBNull.Value) record["oiBracket"] = reader["OI Bracket"];
                    if (reader["Penalty Fines"] != DBNull.Value) record["penaltyFines"] = reader["Penalty Fines"];
                    if (reader["Retailer Coupon"] != DBNull.Value) record["retailerCoupon"] = reader["Retailer Coupon"];
                    if (reader["Returns"] != DBNull.Value) record["returns"] = reader["Returns"];

                    if (reader["Shipment Date"] != DBNull.Value) record["shipmentDate"] = ConvertDateTimeToBCFormat(reader["Shipment Date"]);

                    if (reader["Slotting"] != DBNull.Value) record["slotting"] = reader["Slotting"];
                    if (reader["Trade Other"] != DBNull.Value) record["tradeOther"] = reader["Trade Other"];
                    if (reader["Trade Warehouse"] != DBNull.Value) record["tradeWarehouse"] = reader["Trade Warehouse"];
                    if (reader["Unsalable"] != DBNull.Value) record["unsalable"] = reader["Unsalable"];
                    if (reader["Total Trade Amount"] != DBNull.Value) record["totalTradeAmount"] = reader["Total Trade Amount"];
                    if (reader["Sales Net Trade"] != DBNull.Value) record["salesNetTrade"] = reader["Sales Net Trade"];
                    if (reader["Cost"] != DBNull.Value) record["cost"] = reader["Cost"];
                    if (reader["Inbound Freight"] != DBNull.Value) record["inboundFreight"] = reader["Inbound Freight"];
                    if (reader["WH Inbound Variable"] != DBNull.Value) record["whInboundVariable"] = reader["WH Inbound Variable"];
                    if (reader["WH Overhead - Fixed"] != DBNull.Value) record["whOverheadFixed"] = reader["WH Overhead - Fixed"];
                    if (reader["Total Indirect Cost"] != DBNull.Value) record["totalIndirectCost"] = reader["Total Indirect Cost"];
                    if (reader["Gross Profit"] != DBNull.Value) record["grossProfit"] = reader["Gross Profit"];

                    if (reader["Incremental Load Time Stamp"] != DBNull.Value) record["incrementalLoadTimeStamp"] = ConvertDateTimeToBCFormat(reader["Incremental Load Time Stamp"]);

                    if (reader["DW_Batch"] != DBNull.Value) record["dwBatch"] = reader["DW_Batch"];
                    if (reader["DW_SourceCode"] != DBNull.Value) record["dwSourceCode"] = reader["DW_SourceCode"];

                    if (reader["DW_TimeStamp"] != DBNull.Value) record["dwTimeStamp"] = ConvertDateTimeToBCFormat(reader["DW_TimeStamp"]);
                    //};

                    records.Add(record);
                }
                lastDwId = Convert.ToInt32(records.Last().GetValueOrDefault("dwId"));
                File.WriteAllText("LastTradeDWID.dat", Convert.ToString(lastDwId));
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"SQL Error: {ex.Message}");
        }

        return records;
    }

    static string ConvertDateTimeToBCFormat(object? dateTimeObject)
    {
        const string defaultDateTimeString = "1753-01-01T00:00:00Z";
        if (!(dateTimeObject is DateTime))
            return defaultDateTimeString;
        if (dateTimeObject?.ToString() == "")
            return defaultDateTimeString;

        return Convert.ToDateTime(dateTimeObject).ToString("yyyy-MM-ddTHH:mm:ssZ");
    }

    static string ConvertDateTimeToBCDate(object? dateTimeObject)
    {
        const string defaultDateString = "1753-01-01";
        if (!(dateTimeObject is DateTime))
            return defaultDateString;
        if (dateTimeObject?.ToString() == "")
            return defaultDateString;


        return  Convert.ToDateTime(dateTimeObject).ToString("yyyy-MM-dd");
    }
    static string CreateBatchRequest(List<Dictionary<string, object>> records, string companyName, string bcCompanyId, string endpoint)
    {
        var requests = new List<object>();

        foreach (var record in records)
        {
            requests.Add(new
            {
                method = "POST",
                url = $"companies({bcCompanyId})/{endpoint}",
                headers = new Dictionary<string, string>
                {
                    { "Company", companyName },
                    { "Content-Type", "application/json" }
                },
                body = record
            });
        }

        return JsonSerializer.Serialize(new { requests }, new JsonSerializerOptions { WriteIndented = true });
    }

    static async Task SendDataToBusinessCentral(string jsonBatch, string bcBatchUrl, string userNameToken, string accessToken, HttpClient client)
    {
        try
        {
            //using (HttpClient client = new HttpClient())
            //{

            //    switch (authType)
            //    {
            //        case AuthType.Basic:
            //            string credentials = $"{userNameToken}:{accessToken}";
            //            string base64Credentials = Convert.ToBase64String(Encoding.UTF8.GetBytes(credentials));
            //            client.DefaultRequestHeaders.Add("Authorization", $"Basic {base64Credentials}");
            //            break;
            //        case AuthType.Azure:
            //            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {accessToken}");
            //            break;
            //    }
            //    client.DefaultRequestHeaders.Add("Accept", "application/json");

            var content = new StringContent(jsonBatch, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync(bcBatchUrl, content);

            if (response.IsSuccessStatusCode)
            {

                JsonDocument jsonResponse = JsonDocument.Parse(await response.Content.ReadAsStreamAsync());
                var arrayEnumerator = jsonResponse.RootElement.GetProperty("responses").EnumerateArray();
                while (arrayEnumerator.MoveNext())
                {

                    if (arrayEnumerator.Current.GetProperty("status").GetInt32() == 201)
                    {
                        Console.WriteLine("Data successfully inserted into Business Central.");

                    }
                    else
                    {

                        var code = arrayEnumerator.Current.GetProperty("body").GetProperty("error").GetProperty("code").GetString();
                        var message = arrayEnumerator.Current.GetProperty("body").GetProperty("error").GetProperty("message").GetString();
                        Console.WriteLine($"Code: {code} Error:{message}");
                    }

                }
            }
            else
            {
                string errorResponse = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"Error: {response.StatusCode} - {errorResponse}");
            }
            //}
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error sending data to Business Central: {ex.Message}");
        }
    }
}
