function filtrada = SWF(imgG, sigma2v, jan)
%WIENER_MRF filtragem p�s reconstru��o da imagem.
%
%   DESCRI��O: Um filtro de sinal no dom�nio da imagem, baseado no famoso
%              filtro de Wiener, mas em Campos Aleat�rios Markovianos.
%              Trata-se do filtro de Wiener com MRF Separ�vel.
%   PAR�METROS:
%               imgG - Imagem ruidosa reconstru�da.
%               sigma2v - Vari�ncia do ru�do da imagem ruidosa.
%               jan - Janela do patch da filtragem.
%   RETORNO:
%            filtrada - Imagem filtrada pelo filtro de Wiener MRF Separ�vel

if nargin > 3 || nargin < 1
    error('N�mero inv�lido de argumentos de entrada!');
    pause
elseif nargin == 1
    sigma2v = 22.2;
    jan = 3;
else
    jan = 3;
end

[l,c]=size(imgG);
pad = floor(jan/2);

%cria a m�scara do tamanho [jan jan] para um filtro da m�dia ('average')
mean_filt = fspecial('average', [jan jan]);
imgF = imfilter(imgG, mean_filt); %media da imagem filtrada
%imgF = nlm_pos(imgG);
mf = imfilter(imgF, mean_filt); %media da imagem filtrada
mg = imfilter(imgG, mean_filt); %media da imagem ruidosa

acumulador = zeros(l,c);

for i = -pad : pad
    for j = -pad : pad
        deslocada = circshift(imgF, [i j]);
        diferenca = (deslocada - mf).^2;
        acumulador = acumulador + diferenca;
    end
end
vf = acumulador/((jan^2)-1); % n = jan*jan (f�rmula da vari�ncia)

imgG = padarray(imgG, [pad pad], 'symmetric');
vf = padarray(vf, [pad pad], 'symmetric');
mf = padarray(mf, [pad pad], 'symmetric');

ro = 0.95; % roV = roH

% C�lculo dos pesos para Rgg
pesos_rgg = zeros(jan^2, jan^2);
Ai=0; %Acumulador de linhas
for I = 1 : jan
    for J = 1 : jan
        Ai = Ai + 1;
        Aj = 0;%Acumulador de colunas
        for i = 1 : jan
            for j = 1 : jan
                Aj = Aj+1;
                pesos_rgg(Ai,Aj) = ro^abs(I-i) * ro^abs(J-j);
            end
        end
    end
end

pesos_rff = pesos_rgg(ceil(jan^2/2),:)'; %linha central de Rgg equivale aos pesos de Rff

for i = pad+1 : l+pad
    for j = pad+1 : c+pad
        
        patch = imgG(i-pad : i+pad, j-pad : j+pad) - mf(i-pad : i+pad, j-pad : j+pad); % Define o patch
        
        % C�lculo de Rgg
        Rgg = vf(i,j)*pesos_rgg;
        diag_princ = vf(i,j) * ones(jan^2, 1) + sigma2v; % sigma2v = 1 no dom�nio de Anscombe
        Rgg = Rgg - diag(diag(Rgg)) + diag(diag_princ); % seta a diagonal principal
        
        % C�lculo de Rff
        Rff = vf(i,j) * pesos_rff;
        
        % C�lculo de 'a'
        a = Rgg\Rff;
        
        filtrada(i-pad, j-pad) = mf(i,j) + sum(patch(:) .* a(:));
    end
end

filtrada(vf == 0) = imgF(vf == 0);
end