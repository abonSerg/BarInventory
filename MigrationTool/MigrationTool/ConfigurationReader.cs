using System;
using System.Configuration;

namespace MigrationTool
{
    public interface IConfigurationReader
    {
        Configuration ReadConfig();
    }

    public class ConfigurationReader : IConfigurationReader
    {
        private static readonly Lazy<string> PrefixFactory = new Lazy<string>(() => ConfigurationManager.AppSettings["envVarPrefix"]);
        private static string Prefix => PrefixFactory.Value;

        public Configuration ReadConfig()
        {
            var properties = typeof(Configuration).GetProperties();
            var configuration = new Configuration();

            foreach (var property in properties)
            {
                var envVariableName = Prefix + "_" + property.Name;
                var envVariableStringValue = Environment.GetEnvironmentVariable(envVariableName) ?? "";
                object variableValue = envVariableStringValue;

                if (property.PropertyType.IsArray)
                {
                    variableValue = envVariableStringValue.Split(';');
                }
                if (property.PropertyType == typeof(bool))
                {
                    variableValue = !string.IsNullOrEmpty(envVariableStringValue) && bool.Parse(envVariableStringValue);
                }
                if (property.PropertyType == typeof(int))
                {
                    variableValue = (!string.IsNullOrEmpty(envVariableStringValue)) ? int.Parse(envVariableStringValue) : 0;
                }
                if (property.PropertyType == typeof(TimeSpan))
                {
                    variableValue = (!string.IsNullOrEmpty(envVariableStringValue)) ? TimeSpan.Parse(envVariableStringValue) : TimeSpan.Zero;
                }
                configuration.GetType().GetProperty(property.Name).SetValue(configuration, variableValue);
            }
            return configuration;
        }
    }

    public class Configuration
    {
        public string DbConnectionString { get; set; }
    }




}