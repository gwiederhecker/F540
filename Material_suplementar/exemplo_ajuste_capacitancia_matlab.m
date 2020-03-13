#LIMPA as variáveis e fecha todas as figuras abertas
clear all
close all
#
%**************************************
%% Este parte do script configura as propriedades 
%do grafico padrao do MATLAB,  opcional
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

%*******************************
%CONFIGURA PARAMETROS DOS GRAFICOS
%e necessario baixar este script no Moodle!
set_default_plot_parameters
% *******************************
%CARREGA OS DADOS EXPERIMENTAIS
%*******************************
%Os nomes de arquivos utilizados abaixo devem ser alterados
%para os seus dados.
nomearq = 'vetores-exp1a-grupo_E1_27-Aug-2015_17-38-36.mat'; %string com nome do arquivo
dados = load(nomearq); % carrega os dados na variavel dados
%Neste exemplo o vetor dados possui tres varreduras
%Os dados do passa altas, estao na primeira varredura
pa = dados.dadosobj{3} % o ultimo indice das chaves indica a varredura
%Os dados do passa baixas estao na terceira varredura
pb = dados.dadosobj{5} % o ultimo indice das chaves indica a varredura
%-------------------------------
%o resultado da linha acima deve indicar algo assim
%pa = 
%    param_vec: [1x15 double]
%         vpp1: [1x15 double]
%         vpp2: [1x15 double]
%         fase: [1x15 double]
%    escala_c1: [1x15 double]
%    escala_c2: [1x15 double]
%    escala_dt: [1x15 double]
%        param: 'frequency'
%           id: {'26-Aug-2015 23:02:08 Passa altas '}
%-------------------------------
% **********************************
%GRAFICANDO Tdb=10*log10(T) e fase
%**********************************
Tpa = (pa.vpp2./pa.vpp1).^2; %NOTE O USO DO ./ e .^, ESTE OPERADOR REALIZA DIVISAO, ELEMENTO-A-ELEMENTO
Tpb = (pb.vpp2./pb.vpp1).^2; %NOTE O USO DO ./ e .^, ESTE OPERADOR REALIZA DIVISAO, ELEMENTO-A-ELEMENTO
TDBpa = 10*log10(Tpa); %NOTE O USO DO ./, ESTE OPERADOR REALIZA DIVISAO, ELEMENTO-A-ELEMENTO
TDBpb = 10*log10(Tpb); %NOTE O USO DO ./, ESTE OPERADOR REALIZA DIVISAO, ELEMENTO-A-ELEMENTO
hf1=figure(); % abre um grafico, a variavel hf e um 'handle' para seu grafico
hold on % mantem a mesma janela de grafico
%Vpp1
hf11=subplot(1,2,1); %
semilogx(pa.param_vec,[TDBpa],'o');
hold all; % preserva o grafico anterior quando adicionar o proximo
semilogx(pa.param_vec,[TDBpb],'o');
xlabel('Frequencia (Hz)'); %nome do eixo x
ylabel('Transmitancia (dB)');% nome do eixo y
%Ajustando os limites do eixo para ficar simetrico:
%ylim([-20 1])
%xlim([1e2 1e6])
%Vpp2
hf12=subplot(1,2,2); %
semilogx(pa.param_vec,[pa.fase],'o');
hold all; % preserva o grafico anterior quando adicionar o proximo
semilogx(pa.param_vec,[pb.fase],'o');
xlabel('Frequencia (Hz)'); %nome do eixo x
ylabel('Fase, \phi_2-\phi_1, (graus)');% nome do eixo y
%Ajustando os limites do eixo para ficar simetrico:
%ylim([-20 1])
%xlim([1e2 1e6])
%% ****************************
% FUNCOES TEORICAS
%***************************
%Definindo o valor dos parametros dos componentes:
R=150 % resistencia interna do gerador
%Nos comandos abaixo a parte inicial @(f,x,y) define que 
%a variavel e uma funcao dos argumentos f, x e y.
% Impedancia complexa do capacitor, Zc=-j/(omega*C)
ZC = @(f,C) -j./(2*pi*f*C)  ;
% Impedancia complexa total do circuito, Zt=R+Zc
ZT = @(f,R,C) R + ZC(f,C) ;
% funcao de transferencia e transmitancia
%passa alta
HPA = @(f,R,C) R./ZT(f,R,C) ; 
TPA = @(f,R,C) abs(HPA(f,R,C)).^2; 
%passa paixa
HPB = @(f,R,C) ZC(f,C)./ZT(f,R,C) ; 
TPB = @(f,R,C) abs(HPB(f,R,C)).^2; 
% ****************************
% AJUSTE A CAPACITANCIA AOS DADOS MEDIDOS
%***************************
c_chute = 0.22*1e-6; % valor estimado para c, chute inicial
R = 149; % valor medido de R
xdata = pb.param_vec;
ydata = TDBpa+rand(1,length(TDBpa));
[C,y] = lsqcurvefit(@(C,f) 10*log10( TPA(f,R,C) ),c_chute,xdata,ydata);
fprintf('C ajustado = %3.3e',C) % imprime o valor encontrado de C
%Ajuste calculando os intervalos de confianca, C+-DC
%Para calcular os intervalos de confianca e necessario extrair mais
%parametros do lsqcurvefit:
[C,resnorm,resid,exitflag,output,lambda,J] = lsqcurvefit(@(C,f) 10*log10( TPA(f,R,C) ),c_chute,xdata,ydata); 
conf_int = nlparci(C,resid,'jacobian',J) % o resultado mostra C-deltaC, C+deltaC
% valor ajustado de Ce armazenado na variavel C
% ***************************
% GRAFICOS EM ESCALA LINEAR
%***************************
%vetor de frequencias (Hz)
f=logspace(2,6,500); % 500 pontos linearmente espacados entre 100=10^2 e 1000000=10^6
estilo1='-b'; % estilo de grafico para o circuito PA, veja help plot
estilo2='-r'; % estilo de grafico para circuito PB, veja help plot
%--------------------------------------
%Graficando TdB teorico e fase
%--------------------------------------
%TdB
semilogx(hf11,f,10*log10(TPA(f,R,C)),estilo1); %o ultimo argumento '-' faz o grafico utilizando linha solida
semilogx(hf11,f,10*log10(TPB(f,R,C)),estilo2); %o ultimo argumento '-' faz o grafico utilizando linha solida
%Fase
semilogx(hf12,f,180/pi*angle(HPA(f,R,C)),estilo1); %o ultimo argumento '-' faz o grafico utilizando linha solida
semilogx(hf12,f,180/pi*angle(HPB(f,R,C)),estilo2); %o ultimo argumento '-' faz o grafico utilizando linha solida


