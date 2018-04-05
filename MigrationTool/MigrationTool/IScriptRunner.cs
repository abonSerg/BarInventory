using System.Collections.Generic;

namespace MigrationTool
{
    public interface IScriptRunner
    {
        void RunScripts(Dictionary<string, string> scripts);
    }
}