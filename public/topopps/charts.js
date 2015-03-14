var status_data = [
  { label: "Qualifying", data: 24, color: "#80699b"}, 
  { label: "Developing", data: 18, color: "#528aaa"}, 
  { label: "Negotiations", data: 9, color: "#AA4643"}, 
  { label: "Pending", data: 4 }
];

var progress_data = [
  { label: "Sales", data: 60, color: "#77B34F" },
  { label: "Remaining", data: 40, color: "#efefef"}
];

var performance_data = [
  { label: "In Progress", data: 22, color: "#528aaa" },
  { label: "Won", data: 15, color: "#77B34F" },
  { label: "Loss", data: 4, color: "#E33627" },  
];

var forecast_data = [
  { label: "Sunny", data: 16 },  
  { label: "Cloudy", data: 3, color: "#528AAA" },  
  { label: "Rainy", data: 2, color: "#80699B" },  
  { label: "Hellfire", data: 1, color: "#E33627" },
];

$(document).ready(function () {
    $.plot($("#status-piechart"), status_data, {
         series: { 
           pie: { show: true },
         },
         grid: { hoverable: true },
         legend: { labelBoxBorderColor: "none" },
         tooltip: true,
         tooltipOpts: {
           content: "%p.0% %s",
           shifts: { x: 20, y: 0 },
           defaultTheme: false
         }
    });
    $.plot($("#progress-piechart"), progress_data, {
         series: { pie: { show: true } },
         grid: { hoverable: true },
         legend: { labelBoxBorderColor: "none" },
         tooltip: true,
         tooltipOpts: {
           content: "%p.0% %s",
           shifts: { x: 20, y: 0 },
           defaultTheme: false
         }
    });    
    $.plot($("#performance-piechart"), performance_data, {
         series: { pie: { show: true } },
         grid: { hoverable: true },
         legend: { labelBoxBorderColor: "none" },
         tooltip: true,
         tooltipOpts: {
           content: "%p.0% %s",
           shifts: { x: 20, y: 0 },
           defaultTheme: false
         }
    });
    $.plot($("#forecast-piechart"), forecast_data, {
         series: { pie: { show: true } },
         grid: { hoverable: true },
         legend: { labelBoxBorderColor: "none" },
         tooltip: true,
         tooltipOpts: {
           content: "%p.0% %s",
           shifts: { x: 20, y: 0 },
           defaultTheme: false
         }
    });
    
});
