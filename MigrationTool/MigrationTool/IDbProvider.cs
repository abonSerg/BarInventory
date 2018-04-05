using System;

namespace MigrationTool
{
    public interface IDbProvider
    { 
        void SaveVersionLog(DateTime currentDate, string versionNumber);
        string GetCurrentSiteVersion();
    }
}