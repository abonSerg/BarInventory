using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Dapper;
using DapperExtensions;

namespace MigrationTool
{
    public class DbProvider : IDbProvider
    {
        private class MigrationVersionDto
        {
            public Guid Id { get; set; }
            public string SiteVersion { get; set; }
            public DateTime Date { get; set; }
        }

        private const string ExistingTable =
            @"SELECT Count(*) FROM INFORMATION_SCHEMA.TABLES  WHERE TABLE_NAME = @table";


        public const string CreateVersionTable = @"CREATE TABLE [dbo].[MigrationVersionDto]
                                ([Id] UNIQUEIDENTIFIER NOT NULL,
                                 [SiteVersion] [varchar](30) NOT NULL,
                                 [Date] [datetime] NOT NULL)";

        public const string InsertVersion = @"insert MigrationVersionDto(Id, SiteVersion, [Date])
            values(@Id, @SiteVersion, @Date)";

        public static readonly string GetVersionsQuery = @"SELECT SiteVersion FROM MigrationVersionDto ORDER BY [Date] DESC";

        private readonly IConfigurationReader configurationReader;

        public DbProvider(IConfigurationReader configurationReader)
        {
            this.configurationReader = configurationReader;
        }

        private SqlConnection GetSqlConnection()
        {
            var connectionString = configurationReader.ReadConfig().DbConnectionString;
            return new SqlConnection(connectionString);
        }

        private void CreateMigrationTableIfNotExist()
        {
            Execute(cn =>
            {
                var tableName = "MigrationVersionDto";
                var tableCount = cn.Query<int>(ExistingTable, new { table = tableName });

                if (tableCount.First() == 0)
                    cn.Execute(CreateVersionTable);
            });
        }

        private bool IsMigrationTableExist()
        {
            var result = false;
            Execute(cn =>
            {
                var tableCount = cn.Query<int>(ExistingTable, new {table = "MigrationVersionDto" });
                result = tableCount.First() > 0;
            });

            return result;
        }

        public void SaveVersionLog(DateTime currentDate, string versionNumber)
        {
            CreateMigrationTableIfNotExist();
            var versionDto = new MigrationVersionDto
            {
                Date = currentDate,
                SiteVersion = versionNumber
            };

            Execute(cn =>
            {
                cn.Insert(versionDto);
            });

        }

        public string GetCurrentSiteVersion()
        {
            var result = string.Empty;

            if (!IsMigrationTableExist())
            {
                return result;
            }
            
            Execute(cn =>
            {
                result = cn.QueryFirstOrDefault<string>(GetVersionsQuery);
            });

            return result;
        }

        public void Execute(Action<IDbConnection> act)
        {
            using (var cn = GetSqlConnection())
            {
                cn.Open();
                act(cn);
                cn.Close();
            }
        }

    }
}