%PA8 - winter 2022  - ELEC 4700
%Diode Paramater Extraction

%Alina Jacobson  (7 march 2022)

%Goal In this PA you will investigate the use of non-linear curve fitting for extracting paramaters.
%The device we wish to model is a diode including breakdown and a parasitic parallel leakage resistance. The
%expected physical behaviour is:

% I = ideal diode +parallel resistor - breakdown


clc; 
close all; 
clear all;

set(0, 'DefaultFigureWindowStyle', 'docked')

%1. Generate some data for Is = 0.01pA, Ib = 0.1pA, Vb = 1.3 V and Gp = 0.1 Ω−1.
%==============================================================================
Is= 0.01e-12;           % pA - Forward bias saturation current.
Ib=0.1e-12;             % pA - Breakdown saturation current.
Vb=1.3;                 % V  - Breakdown volatage.
Gp=0.1;                 %1/ohms  - Parasitic parallel conductance.


%Create a V vector from -1.95 to 0.7 volts with 200 steps.
V = linspace(-1.95,0.7,200);


%Create an I vector
I_diode = zeros(size(V));

%I =            ideal diode        + parallel resistor      - breakdown
I_diode= (Is.*(exp((1.2/0.025).*V)-1)) + (Gp.*V) - (Ib.*(exp((-1.2/0.025).*(V+Vb))-1));


%Create a second I vector with 20% random variation in the current 
% to represent experimental noise.
randNoise20=rand(1,length(V)).*0.2;
I_vec2 =I_diode+randNoise20.*I_diode;

%Plot the data using plot() and semilogy()
figure(1)
plot(V, I_diode, V, I_vec2)
title('Q1 Idiode ideal vs Idiode noise (V vs Current) plot()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ideal diode', 'diode with Noise');

figure(2)
semilogy(V, abs(I_diode), V, abs(I_vec2))           %abs() for real values
title('Q1 Idiode ideal vs Idiode noise (V vs Current) semilogy()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ideal diode', 'diode with Noise');



% 2. Polynomial fitting
%==============================================================================
%Create a 4th order and 8th order polynomial fit for the two data vectors.
%Polynomial fitting using polyfit() and polyval().
Fitpoly4th= polyfit(V,I_diode,4);       %computes least squates poly
Fitpoly8th= polyfit(V,I_diode,8);

Fitpoly4th_noise= polyfit(V,I_vec2,4);
Fitpoly8th_noise= polyfit(V,I_vec2,8);

outputValpoly4=polyval(Fitpoly4th,V);    % polyval( poly, at each point in V)
outputValpoly8=polyval(Fitpoly8th,V);    % polyval( poly, at each point in V)

outputValpoly4_noise=polyval(Fitpoly4th_noise,V);
outputValpoly8_noise=polyval(Fitpoly8th_noise,V);


%Add them to your graphs of the data.
%Draw some conclusions!
%Plot the data using plot() and semilogy()
figure(3)
plot(V, I_diode, V, I_vec2,V,outputValpoly4,V,outputValpoly4_noise,V,outputValpoly8,V,outputValpoly8_noise)
title('Q2 FITTING- Idiode ideal vs Idiode noise (V vs Current) plot()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ideal diode', 'diode with Noise','4th orderfit','4th orderfit w/noise', '8th orderfit','8th orderfit w/noise');

figure(4)
semilogy(V, I_diode, V, I_vec2,V,abs(outputValpoly4),V,abs(outputValpoly4_noise),V,abs(outputValpoly8),V,abs(outputValpoly8_noise))   %abs() for real values
title('Q2 FITTING- Idiode ideal vs Idiode noise (V vs Current) semilogy()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ideal diode', 'diode with Noise','4th orderfit','4th orderfit w/noise', '8th orderfit','8th orderfit w/noise');


%Note:
% observing from the plots  at figure 3 and 4, it shows that the 4th order
% models the curve to the diode better than the 8th order fit, where there
% are a lot of  zero inputs to get the fit to model.



% 3. Nonlinear curve fitting to a physical model using fit()
%==============================================================================
%To fit data using fit() you can pass it a string containing the non-linear function to fit such as:
%     fo = fittype(’A.*(exp(1.2*x/25e-3)-1) + B.*x - C*(exp(1.2*(-(x+D))/25e-3)-1)’);
% where A, B, C and D are parameters to be extracted. You can then extract the parameters using:
%     ff = fit(V,I,fo)
% A curve can then be generated using,
%     If = ff(x)


%Create three different fitted curves using:
%(a) Only two fitted paramaters A and C by explictly setting B and D to the values used in equation 1 to generate the data.

%parameters fitted to B=Gb=0.1 and D=Ib=1.3
%fitobject = fit(x,y,fitType) creates the fit to the data in x and y with the model specified by fitType.
fo = fittype('A.*(exp(1.2*x/25e-3)-1) + (0.1).*x - C*(exp(1.2*(-(x+1.3))/25e-3)-1)');

% extract the parameters using: ff = fit(V,I,fo)
fit_2var = fit(V', I_diode', fo);
fit_2var_noise = fit(V', I_vec2', fo);

%A curve can then be generated using, If = ff(x)
Ifit_2var = fit_2var(V);
Ifir_2var_noise = fit_2var_noise(V);

figure(5)
plot(V, Ifit_2var, V, Ifir_2var_noise)
title('Q3a 2 VARs (setting B and D)- Idiode ideal vs Idiode noise (V vs Current) plot()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ifit 2var', 'Ifir 2var noise');


%(b) Using three fitted paramaters A, B and C by explictly setting D to the value used in equation 1 to generate the data.
fo = fittype('A.*(exp(1.2*x/25e-3)-1) + B.*x - C*(exp(1.2*(-(x+1.3))/25e-3)-1)');

fit_3var = fit(V', I_diode', fo);
fit_3var_noise = fit(V', I_vec2', fo);

Ifit_3var = fit_3var(V);
Ifir_3var_noise = fit_3var_noise(V);

figure(6)
plot(V, Ifit_3var, V, Ifir_3var_noise)
title('Q3b 3 VARs (setting D)- Idiode ideal vs Idiode noise (V vs Current) plot()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ifit 3var', 'Ifir 3var noise');


%(c) Fitting all four paramaters A, B, C and D.
fo = fittype('A.*(exp(1.2*x/25e-3)-1) + B.*x - C*(exp(1.2*(-(x+D))/25e-3)-1)');

fit_4var = fit(V', I_diode', fo);
fit_4var_noise = fit(V', I_vec2', fo); 

Ifit_4var = fit_4var(V);
Ifir_4var_noise = fit_4var_noise(V);

figure(7)
plot(V, Ifit_4var, V, Ifir_4var_noise)
title('Q3c 4 VARs (setting no)- Idiode ideal vs Idiode noise (V vs Current) plot()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('Ifit 4var', 'Ifir 4var noise');


%note:
%each output have different plots and  with fitting more variables caused
%error in the output (figure 7) - this is similar to the higher order
%poly.plots




%4. Fitting using the Neural Net model.
%==============================================================================
%To use the Neural Net Toolbox you should use this code:

   inputs = V.';
   targets = I_diode.';                      %I = I_diode
   hiddenLayerSize = 10;
   net = fitnet(hiddenLayerSize);           %returns a function fitting neural network with a hidden layer size of hiddenSizes.
   net.divideParam.trainRatio = 70/100; 
   net.divideParam.valRatio = 15/100; 
   net.divideParam.testRatio = 15/100; 
   [net,tr] = train(net,inputs,targets);
   outputs = net(inputs);
   errors = gsubtract(outputs,targets); 
   performance = perform(net,targets,outputs); 
   view(net);
   Inn = outputs;                            %with no noise


   %inputs = V.';
   targets = I_vec2.';                      %I = I_vec2
   hiddenLayerSize = 10;
   net = fitnet(hiddenLayerSize); 
   net.divideParam.trainRatio = 70/100; 
   net.divideParam.valRatio = 15/100; 
   net.divideParam.testRatio = 15/100; 
   [net,tr] = train(net,inputs,targets);
   outputs = net(inputs);
   errors = gsubtract(outputs,targets); 
   performance = perform(net,targets,outputs); 
   view(net);
   Inn_withNoise = outputs;                            %with noise
   

figure(8)
plot(V, Inn, V, Inn_withNoise)
title('Q4 -Neural Net without noise and noise - plot()');
xlabel('V (volts in)') 
ylabel('I (mA)')
legend('With Noise', 'Without Noise');

%note:
%the neural network produces the same result from figure 1. 
% simply easier. 