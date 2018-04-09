using System;
using System.Linq;
using System.Runtime.InteropServices;
using Fclp.Internals.Extensions;


namespace MigrationTool
{
    public class MigrationService
    {
        private const string InitialSiteVersion = "0.0.0";

        private readonly IScriptRunner scriptRunner;
        private readonly IScriptFileReader scriptReader;
        private readonly IDbProvider dbProvider;

        public MigrationService(IScriptFileReader scriptReader,
                                IScriptRunner scriptRunner,
                                IDbProvider dbProvider)
        {
            this.scriptReader = scriptReader;
            this.scriptRunner = scriptRunner;
            this.dbProvider = dbProvider;
        }

        public void Run(string manualCurrentVersion)
        {
            var siteCurrentVersion = string.IsNullOrEmpty(manualCurrentVersion)
                ? GetCurrentSiteVersion()
                : manualCurrentVersion;

            if (string.IsNullOrEmpty(siteCurrentVersion))
            {
                throw new Exception("Version number is wrong");
            }

            var scriptsInfo = scriptReader.GetOrderedScriptsByVersion(siteCurrentVersion);
      
            if (!scriptsInfo.Scripts.Any())
            {
                Console.WriteLine("Query list is empty");
                return;
            }

            scriptRunner.RunScripts(scriptsInfo.Scripts);
            dbProvider.SaveVersionLog(DateTime.UtcNow, scriptsInfo.ActualVersion);
        }

        private string GetCurrentSiteVersion()
        {
            var siteVersion = dbProvider.GetCurrentSiteVersion();
            return string.IsNullOrEmpty(siteVersion) ? InitialSiteVersion : siteVersion;
        }
    }
}