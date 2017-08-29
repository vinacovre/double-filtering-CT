function sinogram_g = MAP(sinogram, densidade, jan)
%MAP_PONTUAL calcula o estimador MAP com determinada densidade.
%Pr�-filtragem de proje��es.
%
%   O primeiro par�metro � o sinograma das proje��es ruidosas. Ao abrir um
%   arquivo .mat no Matlab, uma vari�vel 'sinogram' � criada contendo o
%   sinograma das proje��es descritas nesse arquivo.
%
%   O par�metro "densidade" serve para identificar a densidade desejada
%   para se realizar a estimativa MAP
%
%   jan � a janela, que por padr�o � 5
%

if nargin < 1
    error('Numero insuficiente de argumentos de entrada');
    pause
elseif nargin == 1
    denisdade = 'gaussiana';
    jan = 5;
elseif nargin == 2
    jan = 5;
    if strcmp(densidade,'gaussiana') ~= 1
        error('Densidade indispon�vel. Adotando densidade Gaussiana...');
        denisdade = 'gaussiana';
    end
elseif nargin > 3
    error('Excedeu o numero de argumentos de entrada');
    pause
end

%   l (linhas) recebe a quantidade (tamanho) de linhas da vari�vel
%   'sinogram'. Do mesmo modo para c (colunas).
[l,c]=size(sinogram);
for i=1 : l % i come�a 1 e vai at� o a qtd de linhas
    
    y = sinogram(i,:);
    
    m = medida_sinal(y,'media',jan); %m�dia
    v = medida_sinal(y,'variancia',jan); %vari�ncia
    
    g = (m - v + sqrt((v-m).^2 + 4 .* v .* y))/2; %estimador MAP gaussiano
    
    sinogram_g(i,:) = g;
end
end
