Zip(sDir, sZip)
{
   If Not FileExist(sZip)
   {
    Header1 := "PK" . Chr(5) . Chr(6)
    VarSetCapacity(Header2, 18, 0)
    file := FileOpen(sZip,"w")
    file.Write(Header1)
    file.RawWrite(Header2,18)
    file.close()
   }
    psh := ComObjCreate( "Shell.Application" )
    pzip := psh.Namespace( sZip )
    pzip.CopyHere( sDir, 4|16 )
    Loop {
        sleep 100
        zippedItems := pzip.Items().count
        ToolTip Zipping in progress..
    } Until zippedItems=1 ;because sDir is just one file or folder
    ToolTip
}

Unzip(Source, Dest)
{
	fileSystem := ComObjCreate("Scripting.FileSystemObject")
    If Not fileSystem.FolderExists(Dest)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
       fileSystem.CreateFolder(Dest)
	shell := ComObjCreate("Shell.Application")
	zippedItems := shell.Namespace( Source ).items().count
	shell.Namespace( Dest ).CopyHere( shell.Namespace( Source ).items, 4|16 )
	Loop {
        sleep 100
        unzippedItems := shell.Namespace( Dest ).items().count
        IfEqual,zippedItems,%unzippedItems%
            break
    }
}
