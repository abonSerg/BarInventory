#r "packages/FAKE.4.37.2/tools/FakeLib.dll"
#r "packages/FAKE.4.37.2/tools/Fake.Deploy.Lib.dll"

open Fake 
open System
open System.IO
open System.Reflection
open Fake.AssemblyInfoFile
open Fake.FakeDeployAgentHelper
open Fake.Git.Branches
open Fake.EnvironmentHelper
open Fake.VersionHelper
open Fake.TeamCityHelper
open Fake.FileHelper
open Fake.Testing.XUnit2
open Fake.ArchiveHelper
open Fake.ArchiveHelper.Zip
open System.Linq
open Fake.Testing.XUnit

// Properties
let buildDir = "./output/"
let srcDir = "../"
let packDir = "../CompDB.MigrationTool"
let testDir  = "./test/"
let deployDir = "./deploy/"

// tools
let fxCopRoot = @".\Tools\FxCop\FxCopCmd.exe"

// version
let majorVersion = "1"
let sprintNumber = "0"
let patchNumber = "0"
let buildNumber = buildVersion.Split('.')

let version = 
    if isLocalBuild then sprintf "%s.%s.%s.0" majorVersion sprintNumber patchNumber
    elif buildServer = Jenkins then sprintf "%s.%s.%s.%s" majorVersion sprintNumber patchNumber buildVersion
    elif buildServer = TeamCity then sprintf "%s.%s.%s.%s" majorVersion sprintNumber patchNumber buildNumber.[0]
    else sprintf "%s.%s.%s.0" buildNumber.[0] buildNumber.[1] buildNumber.[2]




let asmFilePath projectName =
    Path.Combine (srcDir, projectName, @"Properties\AssemblyInfo.cs")

// Targets
Target "Clean" (fun _ ->
     [buildDir; testDir; deployDir] |> List.iter CleanDir
)

Target "BuildApp" (fun _ ->
   let sln = !! (srcDir @@ @"/**/*.sln")
 
   sln |> Seq.iter (fun s -> s 
                             |> RestoreMSSolutionPackages (fun p -> 
                                  { p with 
                                      OutputPath = srcDir @@ "./packages"
                                      ToolPath = srcDir @@ ".nuget/nuget.exe"
                                    }))

   !! (srcDir @@ @"/**/*.sln")  
     |> MSBuildRelease buildDir "Build" 
     |> Log "AppBuild-Output: "
)

Target "RestorePackages" (fun _ ->
    let Restore = (RestorePackage (fun p -> 
        { p with 
            ToolPath = findNuget (srcDir @@ @".nuget/")
            OutputPath = srcDir @@ "packages"
        }))

    !! (packDir @@ "./**/packages.config")
        |> Seq.iter Restore
)


Target "SetVersions" (fun _ ->
    CreateCSharpAssemblyInfo (asmFilePath "CompDB.MigrationTool")
        [Attribute.Version version
         Attribute.FileVersion version]
)



Target "BuildPackForDeploy" (fun _ ->
  MSBuildRelease "output/CompDB.MigrationTool" "Build" [| "../CompDB.MigrationTool" @@ (sprintf @"%s.csproj" "CompDB.MigrationTool") |] |> ignore

  NuGet (fun p -> 
    { p with
        Authors = ["sigmaukraine"]
        Project = "CompDB.MigrationTool"
        Title = "CompDB.MigrationTool"
        Summary = "CompDB.MigrationTool"
        Version = version
        WorkingDir = "output/CompDB.MigrationTool"
        ToolPath = srcDir @@ ".nuget/nuget.exe"
        OutputPath = deployDir
        Publish = false
    }) "template.nuspec"
)


// Dependencies
"Clean"
  ==> "RestorePackages"
  ==> "SetVersions"
  ==> "BuildPackForDeploy"

"Clean"
  ==> "RestorePackages"
  ==> "SetVersions"
  ==> "BuildApp"

RunTargetOrDefault "Default"