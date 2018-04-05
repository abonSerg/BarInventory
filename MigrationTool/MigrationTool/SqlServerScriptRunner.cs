using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using Fclp.Internals.Extensions;

namespace MigrationTool
{
    public class SqlServerScriptRunner : IScriptRunner
    {
        private readonly IConfigurationReader configurationReader;

        public SqlServerScriptRunner(IConfigurationReader configurationReader)
        {
            this.configurationReader = configurationReader;
        }

        public void RunScripts(Dictionary<string, string> scripts)
        {
            var builder = new SqlConnectionStringBuilder(configurationReader.ReadConfig().DbConnectionString)
            {
                MultipleActiveResultSets = false
            };

            using (var sqlConnection = new SqlConnection(builder.ConnectionString))
            {
                sqlConnection.Open();
                var trans = sqlConnection.BeginTransaction();
                scripts.ForEach(s =>
                {
                    var sqlStatements = ParseSqlStatementBatch(s.Value);

                    using (var command = sqlConnection.CreateCommand())
                    {
                        command.CommandType = CommandType.Text;

                        command.Transaction = trans;

                        foreach (var sqlStatement in sqlStatements.Where(sqlStatement => sqlStatement.Length > 0))
                        {
                            command.CommandText = sqlStatement;
                            command.ExecuteNonQuery();
                        }
                    }

                    Console.WriteLine($"{s.Key} query was executed");
                });

                trans.Commit();
                sqlConnection.Close();
            }
        }


        public static string[] ParseSqlStatementBatch(string sqlStatementBatch)
        {
            var sqlStatementBatchSplitter = new Regex(@"^\s*GO\s*\r?$", RegexOptions.Multiline | RegexOptions.IgnoreCase);
            return sqlStatementBatchSplitter.Split(sqlStatementBatch);
        }
    }
}