# grinta

task 

## Description

An application that displays match schedules and results.

## Getting Started

### Dependencies

xcode 14.2
ios Target 16.2
simple project to display match schedules and results. it contain two screen, one for fetch results of api and the second for fetch favorites 
first i would to talk about what architecture that i used . 
i used mvvm (model view view model) with # combine because actually i found that is Easier to develop ,  Easier to test and Easier to maintain. 
after we fetch data we  need to bind it to view so i used combine to do this . because it  include Declarative Code,Cancellability(allowing you to cancel or clean up any ongoing operations, which is especially useful for tasks like network requests and observing UI elements.)and Testability.

## use
every cell contain like button if you press on it will display in favorites screen  


### pod

   SDWebImage ,
   Alamofire , 
   NVActivityIndicatorView , 
   SwiftyJSON , 
   Moya 
### Executing program

to use app just clone it and install pods 

## Help


## Version History
1.0


## screenshots
<img width="431" alt="Screenshot 2023-10-12 at 6 13 17 PM" src="https://github.com/Ahmedshieha/grinta/assets/47928824/1510773e-3723-462f-bab7-cec21a7b94e1">
<img width="428" alt="Screenshot 2023-10-12 at 6 13 09 PM" src="https://github.com/Ahmedshieha/grinta/assets/47928824/384fc8ba-d173-42af-bf53-ed5c50f60b44">


## license 
This project is licensed under the [Ahmedshieha] License - see the LICENSE.md file for details
