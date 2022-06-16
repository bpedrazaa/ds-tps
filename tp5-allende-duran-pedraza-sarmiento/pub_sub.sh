
#prueba mosquitoo 
docker run --rm -it -d cburki/mosquitto-clients mosquitto_sub -h research.upb.edu -p 21212 -t "upb/file/result" 

docker run --rm -it -d cburki/mosquitto-clients mosquitto_pub -h research.upb.edu -p 21212 -t "upb/file/search" -m "dir"

docker run --rm -it -d cburki/mosquitto-clients mosquitto_pub -h research.upb.edu -p 21212 -t "upb/file/search" -m "find pom.xml"
docker run --rm -it -d cburki/mosquitto-clients mosquitto_pub -h research.upb.edu -p 21212 -t "upb/file/search" -m "find sys"