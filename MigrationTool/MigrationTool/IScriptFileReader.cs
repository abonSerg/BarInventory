using System.Collections.Generic;

namespace MigrationTool
{
    public interface IScriptFileReader
    {
        ScriptsVersionInfo GetOrderedScriptsByVersion(string versionNumber);
    }
}