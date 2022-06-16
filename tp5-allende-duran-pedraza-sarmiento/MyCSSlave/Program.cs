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
var input = new RegistryInfo { IpAddress = myIP, Name = "CSharp-Slave" };
var channel = GrpcChannel.ForAddress("https://" + Environment.GetEnvironmentVariable("SERVER") + ":50051");
var genClient = new GeneralService.GeneralServiceClient(channel);
var reply = await genClient.RegisterToMasterAsync(input);
app.Run();
