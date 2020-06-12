% Open the Austin area geographical area map and plot it using OpenStreetMap functions
openstreetmap_filename = 'austin.osm';
map_img_filename = 'map.png';
[parsed_osm, osm_xml] = parse_openstreetmap(openstreetmap_filename);
fig = figure;
ax = axes('Parent', fig);
hold(ax, 'on');
plot_way(ax, parsed_osm, map_img_filename)
hold on


Initial_BS_Long = [];
Initial_BS_Lat = [];

%Generate Randomly Placed BS accross the map
NbOfBS = 110;
for i=1:1:(NbOfBS)
x = -97.7346 - randi([0,118])/10000;  
y = 30.2757 + randi([0,75])/10000;  
plot(x,y,'-^','LineWidth', 1, 'MarkerEdgeColor', 'black',  'MarkerFaceColor', 'blue', 'MarkerSize', 7)
%viscircles([BS_Long BS_Lat],0.000515, 'Color', 'r')
Initial_BS_Long = [Initial_BS_Long ; x];
Initial_BS_Lat = [Initial_BS_Lat ; y];
end


Initial_MS_Longitude = [];
Initial_MS_Latitude = [];

%Generate Randomly Placed Mobile Stations accross the map
NumberOfUsers = 750;
for i=1:1:(NumberOfUsers)
x = -97.7346 - randi([0,118])/10000;  
y = 30.2757 + randi([0,75])/10000;  
plot(x,y,'r+', 'MarkerSize', 10, 'Color', 'm')
Initial_MS_Longitude = [Initial_MS_Longitude ; x];
Initial_MS_Latitude = [Initial_MS_Latitude ; y];
end

%Create a vector to keep track of already assigned MS
Initial_MS_Status = zeros(NumberOfUsers,1);


for current_BS = 1:1:NbOfBS
BS_Long = Initial_BS_Long(current_BS);
BS_Lat = Initial_BS_Lat(current_BS);


%Check the Nearest MSs to BTS (Based on a defined range) and add them to
MS_Longitude = [];
MS_Latitude = [];
AddedUsers = 0;

for i=1:1:(NumberOfUsers)
z = get_distance(BS_Long,Initial_MS_Longitude(i),BS_Lat,Initial_MS_Latitude(i)) * 1000; %distance in meters
if z < 53 && Initial_MS_Status(i) ~= 1
    Initial_MS_Status(i) = 1;
    MS_Longitude = [MS_Longitude; Initial_MS_Longitude(i)];
    MS_Latitude = [MS_Latitude; Initial_MS_Latitude(i)];
    AddedUsers = AddedUsers + 1;
end
end


a = max(MS_Longitude);
b = min(MS_Longitude);
c = min(MS_Latitude);
d = max(MS_Latitude);
Power_Received = [];

%Simulation Parameters
EIRP = 43;
Gr  = 0;
f = 28*10^9;
n=2.89;
SF=7.1;
Pth = -78;
key = 0;
Optimal_Long = [];
Optimal_Lat = [];
NbOfOptimalLocations = 0;

%Find all the optimal locations and store them
for i = a:-0.0001:b
    for j = c:0.0001:d   
    BS_Long = i;
    BS_Lat = j;
    Power_Received = [];
        for k=1:1:AddedUsers
        z = get_distance(BS_Long,MS_Longitude(k),BS_Lat,MS_Latitude(k)) * 1000; %distance in meters
        PL = 20*log10((4*pi*f)/(3*10^8)) + 10*n*log10(z) + SF;
        Pr = EIRP - PL - 0.016*z - 0.0035*z + Gr;
        Power_Received = [Power_Received;Pr];
        end      
        if min(Power_Received) > Pth
            disp('optimal location has been found')
            NbOfOptimalLocations = NbOfOptimalLocations + 1;
            Optimal_Long = [Optimal_Long; BS_Long];
            Optimal_Lat = [Optimal_Lat; BS_Lat];
        end
    end
end

Summed_Distances = [];


%Find the summed BS_MS distances for each optimal location and store them
for i=1:1:NbOfOptimalLocations
   temp_sum = 0;
   for k=1:1:AddedUsers
   z = get_distance(Optimal_Long(i),MS_Longitude(k),Optimal_Lat(i),MS_Latitude(k)) * 1000; %distance in meters
   temp_sum = temp_sum + z;
   end 
   Summed_Distances = [Summed_Distances; temp_sum];
end

%Obatin the minum distance and its index which will correspong to the index
%of the optimal location as well
[M,I] = min(Summed_Distances);

%Plot the BS and BS_MS Distances for the optimal location found
plot(Optimal_Long(I),Optimal_Lat(I),'-^','LineWidth',1,'MarkerEdgeColor','black', 'MarkerFaceColor','red','MarkerSize',7)
for i =1:1:AddedUsers
    plot([Optimal_Long(I) MS_Longitude(i)], [Optimal_Lat(I) MS_Latitude(i)], 'Linewidth', 1, 'color', 'red')
end


%Calculate the Received Power at the optimal Location
Power_Received = []; %Clear Power Received
for k=1:1:AddedUsers
  z = get_distance(Optimal_Long(I),MS_Longitude(k),Optimal_Lat(I),MS_Latitude(k)) * 1000; %distance in meters
  PL = 20*log10((4*pi*f)/(3*10^8)) + 10*n*log10(z) + SF;
  Pr = EIRP - PL - 0.016*z - 0.0035*z + Gr;
  Power_Received = [Power_Received;Pr];
end   
end

%Calculate the Number of Served and Unserved Mobile Stations
Served = ['The number of served MSs is: ', num2str(sum(Initial_MS_Status(:) == 1))];
disp(Served)
Unserved = ['The number of unserved MSs is: ', num2str(sum(Initial_MS_Status(:) == 0))];
disp(Unserved)

%Plot Title
title('Mobile Stations & Base Stations')

%Compute the Efficiency
disp(sum(Initial_MS_Status(:) == 1)/NumberOfUsers *100)
