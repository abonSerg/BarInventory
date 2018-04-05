using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using Fclp.Internals.Extensions;

namespace MigrationTool
{
    public class ScriptFileReader : IScriptFileReader
    {
        private const string MigrationFilesPattern = @"^(migration_script_)(\d+(?:\.\d+)+)(.sql)$";
        private const string StartFileName = "migration_script_";
        private const string EndFileName = ".sql";
        private const string ScriptsFolderName = "\\migration";


        public ScriptsVersionInfo GetOrderedScriptsByVersion(string versionNumber)
        {
            var currentVersion = new Version(versionNumber);

            var regex = new Regex(MigrationFilesPattern);

            var currentFoldePath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

            var filePathes = Directory.GetFiles(currentFoldePath + ScriptsFolderName)
                                       .Where(x => regex.IsMatch(x.Split('\\').Last()));

            var scripts =  filePathes.ToDictionary(x => new Version(TrimVersion(GetFileVersion(x))), x => x)
                              .OrderBy(x => x.Key)
                              .Where(x => x.Key > currentVersion)
                              .ToDictionary(x => x.Value.Split('\\').Last(), x => File.ReadAllText(x.Value));
                              //.ToDictionary(x => x.Value.Split('\\').Last(), x => x.Value);

            var actualVersion = scripts.Any()
                ? TrimVersion(GetFileVersion(scripts.Last().Key.Split('\\').Last()))
                : string.Empty;

            return new ScriptsVersionInfo
            {
                Scripts = scripts,
                ActualVersion = actualVersion
            };
        }

        private static string TrimVersion(string value)
        {
            var result = Regex.Replace(value, @"(\.0+)+$", "");

            if (result.Contains('.'))
                return result;

            return result + ".0";
        }

        public static string GetFileVersion(string fileName)
        {
            var nameWithoutPath = fileName.Split('\\').Last();

            var startIndex = nameWithoutPath.IndexOf(StartFileName, StringComparison.Ordinal) + StartFileName.Length;
            var endIndex = nameWithoutPath.IndexOf(EndFileName, StringComparison.Ordinal);
            return nameWithoutPath.Substring(startIndex, endIndex - startIndex);
        }
    }

    public class ScriptsVersionInfo
    {
        public Dictionary<string, string> Scripts { get; set; }
        public string ActualVersion { get; set; }
    }
}
