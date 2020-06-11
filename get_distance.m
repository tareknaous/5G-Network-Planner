%This function is used to calculate the distance in kilometers between 2 points given
%their longitude and latitude values
%The obtained distance is based on the Haversine formula
%(Haversine: http://en.wikipedia.org/wiki/Haversine_formula)

function[distance] = get_distance (lon1, lon2, lat1, lat2)

radius=6371;

deltaLat=(lat2*pi/180)-(lat1*pi/180);
deltaLon=(lon2*pi/180)-(lon1*pi/180);

a=sin((deltaLat)/2)^2 + cos(lat1)*cos(lat2) * sin(deltaLon/2)^2;
c=2*atan2(sqrt(a),sqrt(1-a));

distance = radius*c; 

end