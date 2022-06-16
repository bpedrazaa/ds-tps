using Grpc.Core;
//using MyCSSlave.Protos;
namespace MyCSSlave.Services
{
    public class GenService : GeneralService.GeneralServiceBase
    {
        private readonly ILogger<GenService> _logger;
        private string sourceDirectory = "/proc";
        public GenService(ILogger<GenService> logger)
        {
            _logger = logger;
        }
        public override Task<FileInfoList> GetFileInfo(Empty request, ServerCallContext context)
        {
            FileInfoList infoList = new FileInfoList();
            int id = 0;
            
            try
            {
                Console.WriteLine( Environment.GetEnvironmentVariable("SERVER"));
                var txtFiles = Directory.EnumerateFiles(this.sourceDirectory, "*.*");

                foreach (string currentFile in txtFiles)
                {
                    id++;
                    FileInfo myFile = new FileInfo();

                    string fileName = currentFile.Substring(this.sourceDirectory.Length);
                    myFile.FileName = fileName;
                    long mynum = 0;
                    myFile.Size = Convert.ToUInt32(mynum);
                    System.IO.FileInfo fi = new System.IO.FileInfo(currentFile);
                    if (fi.Exists)
                    {
                        myFile.Size = Convert.ToUInt32(fi.Length);
                    }
                    else 
                    { 
                        myFile.Size = Convert.ToUInt32(mynum);
                    }
                    myFile.SlaveId = System.Environment.MachineName;
                    infoList.FileInfoList_.Add(myFile);
                    Console.WriteLine(fileName);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }

            return Task.FromResult(infoList);
        }
        public override Task<FileInfo> SearchFile(FileName request, ServerCallContext context)
        {
            string nombreBuscado = request.FileName_;
            FileInfo myFile = new FileInfo();
            int id = 0;
            
            try
            {
                var txtFiles = Directory.EnumerateFiles(this.sourceDirectory, "*.*");

                foreach (string currentFile in txtFiles)
                {
                    id++;


                    string fileName = currentFile.Substring(this.sourceDirectory.Length);

                    System.IO.FileInfo fi = new System.IO.FileInfo(currentFile);
                    if (fi.Exists)
                    {
                        if (fileName == nombreBuscado)
                        {
                            myFile.FileName = fileName;
                            myFile.Size = Convert.ToUInt32(fi.Length);
                            myFile.SlaveId = System.Environment.MachineName;
                            Console.WriteLine(fileName);
                            return Task.FromResult(myFile);
                        }
                    }


                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
            return Task.FromResult(myFile);
        }
    }
}
