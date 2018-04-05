using System;
using Fclp;

namespace MigrationTool
{
    class Program
    {
        static void Main(string[] args)
        {
            var parser = new FluentCommandLineParser<Arguments>();
            parser.Setup(arg => arg.VersionNumber)
               .As('v', "version");

            parser.Parse(args);

            var confReader = new ConfigurationReader();
            var service = new MigrationService(new ScriptFileReader(), new SqlServerScriptRunner(confReader),
                new DbProvider(confReader));

            service.Run(parser.Object.VersionNumber);
        }
    }

    public class Arguments
    {
        public string VersionNumber { get; set; }
    }
}
