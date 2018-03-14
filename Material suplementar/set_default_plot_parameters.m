%**************************************
%% Este script configura as propriedades 
%do grafico padrao do MATLAB
%**************************************
%figure properties:
clc
altura = 10/1.6;
largura = 10;
screenres = 110; %resolucao da tela, ajustar para ficar compativel com arquivo PDF
set(0,'defaultFigureColor','w')
set(0,'defaultFigureUnits','centimeters')
set(0,'defaultFigurePosition',[3 3 largura altura])
set(0,'defaultFigurePaperUnits','centimeters')
set(0,'defaultFigurePaperSize',[largura altura])
set(0,'defaultFigureRenderer','painters')
set(0,'ScreenPixelsPerInch',screenres)
% line properties
colororder=[0 0.2 0.8; 0.8 0 0; 0 0.8 0];
set(0,'defaultAxesColorOrder',colororder);
set(0,'defaultAxesOuterPosition', [0 0 1 1])
set(0,'defaultAxesFontSize',8);
set(0,'defaultAxesFontName','Arial');
set(0,'defaultLineLineWidth',1.5)
set(0,'defaultLineMarkerSize',4)
set(0,'defaultLineMarkerFaceColor',[0.301960796117783 0.745098054409027 0.933333337306976])

