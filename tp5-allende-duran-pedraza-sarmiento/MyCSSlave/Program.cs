using Grpc.Net.Client;
using MyCSSlave.Services;
using System.Net;

var builder = WebApplication.CreateBuilder(args);

// Additional configuration is required to successfully run gRPC on macOS.
// For instructions on how to configure Kestrel and gRPC clients on macOS, visit https://go.microsoft.com/fwlink/?linkid=2099682

// Add services to the container.
builder.Services.AddGrpc();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.MapGrpcService<GreeterService>();
app.MapGrpcService<GenService>();
app.MapGet("/", () => "Communication with gRPC endpoints must be made through a gRPC client. To learn how to create a client, visit: https://go.microsoft.com/fwlink/?linkid=2086909");
string hostName = Dns.GetHostName();
string myIP = Dns.GetHostByName(hostName).AddressList[0].ToString();
Console.WriteLine(hostName);
Console.WriteLine(myIP);
Console.WriteLine("ENV VAR: "+Environment.GetEnvironmentVariable("SERVER"));

var input = new RegistryInfo { IpAddress = myIP, Name = "CSharp-Slave" };

string masterIP = Dns.GetHostByName(Environment.GetEnvironmentVariable("SERVER")).AddressList[0].ToString();
string addr = "https://" +masterIP+ ":50051";
Console.WriteLine("LINK CHANNEL: "+addr);
var channel = GrpcChannel.ForAddress(addr);
var genClient = new GeneralService.GeneralServiceClient(channel);
var reply = await genClient.RegisterToMasterAsync(input);
app.Run();
