-- =============================================================================
-- O ESPANHOL (oespanhol.com.br) — Carga Inicial Idempotente (MySQL 11.4)
-- 17 Comunidades Autônomas, 56 Pratos Regionais + 3 Extras (59 Itens),
-- 8 Zonas Refrigeradas do DF e 4 Rotas do Sommelier
-- =============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET time_zone = '-03:00';

START TRANSACTION;

-- -----------------------------------------------------------------------------
-- 1. As 17 Comunidades Autônomas da Espanha
-- -----------------------------------------------------------------------------
INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('andaluzia', '01', 'Andaluzia', 'Andalucía', 'Sevilha', 'sul', 'Sul & Dehesa', '#B55038', 'rgba(181, 80, 56, 0.11)', 'mudejar', 'Geometria Mudéjar · Sevilha & Alhambra', '["D.O.P. Jabugo","D.O. Jerez-Xérès-Sherry","Jaén AOVE"]', 'Ouro líquido dos olivais de Jaén, jamón de serra e brisa de Jerez.', 'Entre pátios caiados de branco e azulejos mudéjares, a mesa andaluza celebra o contraste perfeito entre frescor e profundidade: salmorejos aveludados, atum vermelho de almadraba, azeites de colheita verde e o lendário Jamón 100% Bellota de Jabugo.', '“Sirva o Fino de Jerez em copita bem gelada a 7 °C junto às primeiras lascas de Jamón de Jabugo — o ritual clássico de fim de tarde em Sevilha.”', 245, 318, 1, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('aragao', '02', 'Aragão', 'Aragón', 'Zaragoza', 'interior', 'Meseta & Interior', '#A45D2A', 'rgba(164, 93, 42, 0.11)', 'aragon', 'Lacería Mudéjar · Teruel & Zaragoza', '["D.O.P. Jamón de Teruel","I.G.P. Ternasco","D.O. Campo de Borja"]', 'Cozinha de montanha e Pireneus, cordeiro macio e Garnachas centenárias.', 'Terra de torres mudéjares em tijolo aparente e vales dos Pireneus, Aragão oferece uma gastronomia honesta e aromática, onde o cordeiro Ternasco, os presuntos curados no ar seco de Teruel e os tintos de Garnacha velha brilham à mesa.', '“Aqueça o Ternasco em forno alto nos últimos 10 minutos para pururucar a pele e sirva com um Campo de Borja de vinhas velhas.”', 382, 146, 2, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('asturias', '03', 'Astúrias', 'Principado de Asturias', 'Oviedo', 'norte', 'Norte Atlântico', '#3B6342', 'rgba(59, 99, 66, 0.11)', 'asturias', 'Cruz de la Victoria · Picos de Europa', '["I.G.P. Faba Asturiana","D.O.P. Cabrales","D.O.P. Sidra de Asturias"]', 'Verdes Picos de Europa, panelas de fabada, queijos de caverna e sidra natural.', 'Onde as montanhas verdes encontram o mar Cantábrico, a mesa asturiana é generosa e reconfortante: feijões manteigosos da Granja cozidos lentamente com compango defumado, queijos azuis maturados em grutas naturais e sidra ácida escanciada do alto.', '“Sirva a Sidra Natural bem fresca vertendo a garrafa do alto para oxigenar — o chamado escanciado das sidrerías de Oviedo.”', 186, 74, 3, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('baleares', '04', 'Ilhas Baleares', 'Illes Balears', 'Palma de Maiorca', 'mediterraneo', 'Mediterrâneo & Ilhas', '#335C75', 'rgba(51, 92, 117, 0.11)', 'baleares', 'Rosa dos Ventos · Tramontana & Mediterrâneo', '["I.G.P. Sobrassada de Mallorca","D.O.P. Mahón-Menorca","I.G.P. Ensaïmada"]', 'Brisa de Maiorca e Menorca em embutidos de pimentón, queijos marinhos e folhados.', 'A gastronomia do arquipélago balear combina a memória camponesa da Serra de Tramuntana com os ventos salinos do Mediterrâneo. Sobrassada untuosa de porco negro, queijos curados em pedra marinha e a inconfundível ensaïmada formam um repertório singular.', '“Espalhe a Sobrassada de Mallorca sobre pão rústico tostado ainda quente e finalize com duas gotas de mel de flor de laranjeira.”', 525, 235, 4, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('canarias', '05', 'Ilhas Canárias', 'Canarias', 'Las Palmas & Santa Cruz', 'mediterraneo', 'Mediterrâneo & Ilhas', '#9A552A', 'rgba(154, 85, 42, 0.11)', 'canarias', 'Sol Atlântico & Basalto Vulcânico', '["D.O.P. Papas Antiguas","D.O.P. Queso Majorero","D.O. Lanzarote"]', 'Sabores vulcânicos do Atlântico: mojos vibrantes, queijos de cabra e Malvasía.', 'Moldadas pela cinza vulcânica e pelos ventos alísios, as sete ilhas Canárias criaram uma cozinha única na Espanha — onde molhos de cominho, coentro e pimenta palmera encontram queijos de cabra Majorero e vinhos brancos minerais nascidos em crateras de lava.', '“Sirva as Papas Arrugadas com a casca salgada intacta, alternando entre o Mojo Rojo picante e o Mojo Verde aromático de coentro.”', 112, 386, 5, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('cantabria', '06', 'Cantábria', 'Cantabria', 'Santander', 'norte', 'Norte Atlântico', '#2E556B', 'rgba(46, 85, 107, 0.11)', 'cantabria', 'Estela Cântabra · Mar Cantábrico', '["Santoña · Anchoas","D.O.P. Quesucos de Liébana","I.G.P. Sobao Pasiego"]', 'As melhores anchovas do mundo em Santoña, pastos verdes e manteiga pasiega.', 'Entre falésias batidas pelo Mar Cantábrico e os vales neblinados de Pas e Liébana, a Cantábria é sinônimo de excelência artesanal: anchovas limpas à mão uma a uma em Santoña, queijos de montanha e confeitaria amanteigada de aroma inesquecível.', '“Retire a lata de Anchoas de Santoña da geladeira 15 minutos antes e sirva sobre pão tostado com manteiga pasiega fresca.”', 242, 74, 6, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('castela-la-mancha', '07', 'Castela-La Mancha', 'Castilla-La Mancha', 'Toledo', 'interior', 'Meseta & Interior', '#AE6A22', 'rgba(174, 106, 34, 0.11)', 'mancha', 'Moinhos de Consuegra & Flor de Açafrão', '["D.O.P. Queso Manchego","D.O.P. Azafrán de La Mancha","I.G.P. Mazapán de Toledo"]', 'A terra de Dom Quixote: queijo Manchego de leite cru, açafrão ouro e Toledo.', 'Sob planícies douradas pontuadas por moinhos brancos, Castela-La Mancha guarda três joias absolutas da despensa ibérica: o verdadeiro Manchego artesão de leite cru de ovelha, os estigmas rubi do açafrão colhido ao amanhecer e a doçaria histórica de Toledo.', '“Corte o Manchego 12 meses em triângulos finos, regue com azeite virgem extra e sirva junto a um Pisto morno com ovo mole.”', 294, 238, 7, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('castela-e-leao', '08', 'Castela e Leão', 'Castilla y León', 'Valladolid', 'interior', 'Meseta & Interior', '#7B2430', 'rgba(123, 36, 48, 0.11)', 'aqueduto', 'Arcos do Aqueduto de Segóvia & Ribera', '["D.O. Ribera del Duero","D.O.P. Guijuelo","I.G.P. Cecina de León"]', 'Assados monumentais de Segóvia, Guijuelo, Cecina de León e tintos do Douro.', 'Coração histórico da coroa castelhana, Castela e Leão reúne algumas das maiores expressões da mesa espanhola: a elegância de Ribera del Duero, a cura fina de Guijuelo, a carne defumada de León e a tradição secular dos assados em forno a lenha.', '“Aqueça o Cochinillo confitado até a pele estalar, decante o Ribera del Duero e comece com fatias translúcidas de Cecina de León com azeite.”', 224, 142, 8, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('catalunha', '09', 'Catalunha', 'Cataluña / Catalunya', 'Barcelona', 'mediterraneo', 'Mediterrâneo & Ilhas', '#8F2632', 'rgba(143, 38, 50, 0.11)', 'panot', 'Panot Flor de Barcelona · Modernismo Catalão', '["D.O. Cava","D.O.Q. Priorat","I.G.P. Llonganissa de Vic"]', 'Mar e montanha, embutidos de Vic, escalivada na brasa e borbulhas de Cava.', 'Da elegância modernista de Barcelona às encostas de xisto do Priorat e da Costa Brava, a culinária catalã domina a arte do ''mar i muntanya'': pão esfregado com tomate maduro, legumes assados na brasa com anchovas de l''Escala e grandes Cavas de método tradicional.', '“Esfregue meio tomate maduro sobre pão rústico tostado, regue com azeite, sal em flocos e deite fatias de Fuet de Vic — o ritual do Pa amb Tomàquet.”', 454, 136, 9, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('valencia', '10', 'Comunidade Valenciana', 'Comunitat Valenciana', 'Valência', 'mediterraneo', 'Mediterrâneo & Ilhas', '#BD7722', 'rgba(189, 119, 34, 0.12)', 'valencia', 'Azulejaria de Manises · Laranjeiras do Levante', '["D.O. Arroz de Valencia","I.G.P. Turrón de Jijona","D.O. Chufa de Valencia"]', 'O berço sagrado da Paella, do Arroz Bomba da Albufera e do Turrón de amêndoas.', 'Banhada pelo sol do Levante e decorada por azulejos cerâmicos de Manises, Valência transformou o arroz em cultura. Da lagoa da Albufera nasce o grão Bomba que absorve o caldo aromático sem desmanchar, encerrando o almoço de domingo com o autêntico Turrón de Jijona.', '“Deixe o arroz repousar 5 minutos após apagar o fogo e não tenha pressa — o fundo levemente caramelizado (socarrat) é a alma da Paella.”', 406, 232, 10, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('extremadura', '11', 'Extremadura', 'Extremadura', 'Mérida', 'sul', 'Sul & Dehesa', '#5E6235', 'rgba(94, 98, 53, 0.12)', 'bellota', 'Dehesa de Azinheiras · Cáceres & Mérida', '["D.O.P. Dehesa de Extremadura","D.O.P. Torta del Casar","D.O.P. Pimentón de La Vera"]', 'Bosques infinitos de azinheiras, a cremosa Torta del Casar e o Pimentón defumado.', 'Extremadura é o santuário intocado da dehesa espanhola. De suas pastagens nascem três tesouros cultuados por chefs do mundo todo: a Torta del Casar que se come de colher, o Pimentón de La Vera seco sobre fumaça de carvalho e o Jamón Ibérico extremo-ocidental.', '“Retire a tampa da Torta del Casar com uma faca como se fosse um cálice e mergulhe torradas de pão rústico no creme quente de ovelha.”', 176, 244, 11, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('galicia', '12', 'Galícia', 'Galicia', 'Santiago de Compostela', 'norte', 'Norte Atlântico', '#3A5A6B', 'rgba(58, 90, 107, 0.11)', 'vieira', 'Concha de Vieira · Caminho de Santiago', '["D.O. Rías Baixas","D.O.P. Mexillón de Galicia","I.G.P. Tarta de Santiago"]', 'O Atlântico em estado puro: polvo à feira, mariscos das rías e Albariño mineral.', 'Terra de pedra de granito, névoa oceânica e peregrinos, a Galícia venera o produto em sua pureza máxima. Polvo cozido no ponto exato sobre tábuas de madeira, mexilhões gigantes das Rías Baixas, Albariños salinos e a Tarta de Santiago de amêndoas.', '“Aqueça o Polvo à Feira em banho-maria por 4 minutos, disponha sobre batatas cozidas, polvilhe Pimentón de La Vera, flor de sal e regue generosamente com azeite.”', 112, 92, 12, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('madri', '13', 'Comunidade de Madri', 'Comunidad de Madrid', 'Madri', 'interior', 'Meseta & Interior', '#7A2033', 'rgba(122, 32, 51, 0.11)', 'madri', 'Arcos da Plaza Mayor · Tradição Castiza', '["D.O. Vinos de Madrid","Aceitunas de Campo Real","Vermut de Grifo"]', 'A hora do vermute nas tabernas centenárias, callos aromáticos e alma castiza.', 'Madri sintetiza toda a Espanha em suas tabernas históricas de balcão de estanho e azulejos pintados à mão. O domingo começa invariavelmente na ''hora del vermut'' com azeitonas de Campo Real, seguido pelos clássicos de panela de longa cocção.', '“Sirva o Vermute Madrilenho em copo baixo com pedra de gelo grande, meia rodela de laranja e uma azeitona de Campo Real no palito.”', 268, 192, 13, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('murcia', '14', 'Região de Múrcia', 'Región de Murcia', 'Múrcia', 'mediterraneo', 'Mediterrâneo & Ilhas', '#9E6926', 'rgba(158, 105, 38, 0.11)', 'murcia', 'Huerta de Europa · Limoeiros & Jumilla', '["D.O.P. Arroz de Calasparra","D.O.P. Queso de Murcia al Vino","D.O. Jumilla"]', 'A Horta da Europa: arroz de Calasparra, queijo banhado em vinho e Monastrell.', 'Conhecida como ''La Huerta de Europa'', Múrcia une hortas solares de citros e pimentões, o lendário arroz de montanha de Calasparra e tintos potentes de uva Monastrell de Jumilla — que inclusive dão banho à casca rubi do seu queijo mais famoso.', '“Acompanhe o Queijo de Murcia al Vino com amêndoas tostadas e um gole de Jumilla Monastrell — a combinação perfeita de fruta e cremosidade.”', 374, 294, 14, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('navarra', '15', 'Navarra', 'Comunidad Foral de Navarra', 'Pamplona', 'norte', 'Norte Atlântico', '#9E2B2B', 'rgba(158, 43, 43, 0.11)', 'navarra', 'Correntes de Navarra · Ribeira do Ebro', '["I.G.P. Espárrago de Navarra","D.O.P. Piquillo de Lodosa","I.G.P. Pacharán Navarro"]', 'Ouro branco da ribeira do Ebro, pimentões assados na lenha e Pacharán.', 'Ponte entre os Pireneus e o vale fértil do Ebro, Navarra é celebrada pela delicadeza incomparável de sua horta — espargos brancos colhidos antes de ver a luz do sol e pimentões piquillo de Lodosa assados na chama e descascados a seco sem tocar água.', '“Sirva os Espargos Brancos de Navarra apenas em temperatura ambiente com um fio de azeite virgem extra e flor de sal — nada mais.”', 356, 92, 15, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('pais-basco', '16', 'País Basco', 'Euskadi', 'Vitória-Gasteiz · San Sebastián', 'norte', 'Norte Atlântico', '#2C5444', 'rgba(44, 84, 68, 0.11)', 'lauburu', 'Lauburu Basco · Parte Vieja de Donostia', '["D.O.P. Idiazabal","D.O. Getariako Txakolina","Rioja Alavesa"]', 'Capital mundial dos pintxos, queijo Idiazabal defumado, bacalhau e Txakoli.', 'Com a maior concentração de cultura gastronômica da Europa, o País Basco elevou a barra de pintxos de San Sebastián e Bilbao à categoria de alta arte. Das sociedades gastronômicas (txokos) nascem a Gilda original, o bacalhau ao pil-pil e o Idiazabal defumado em madeira de faia.', '“Uma Gilda se come de uma só mordida — salgada da anchova, picante da guindilla e untuosa da azeitona — seguida imediatamente por um gole fresco de Txakoli.”', 304, 76, 16, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

INSERT INTO regions (slug, code, name, spanish_name, capital, macro_region, macro_label, accent_hex, accent_soft, motif_key, motif_label, dops_json, tagline, story, ritual, map_x, map_y, sort_order, is_active)
VALUES ('la-rioja', '17', 'La Rioja', 'La Rioja', 'Logroño', 'norte', 'Norte Atlântico', '#6B1D2B', 'rgba(107, 29, 43, 0.11)', 'rioja', 'Videiras de Tempranillo · Barrio de la Estación', '["D.O.Ca. Rioja","I.G.P. Chorizo Riojano","I.G.P. Pimiento Riojano"]', 'A pátria do vinho espanhol, Calle Laurel, chorizo na lenha e Gran Reservas.', 'Menor comunidade peninsular, mas gigante na mesa e na taça. Em Logroño e Haro, o tempo corre no ritmo das barricas de carvalho: vinhos Gran Reserva de longevidade lendária acompanham batatas à riojana, pimentões assados e peras cozidas no próprio tinto.', '“Decante o Rioja Gran Reserva 2016 por 30 minutos para abrir suas notas de cereja seca, couro fino e baunilha antes do primeiro brinde.”', 314, 112, 17, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), spanish_name = VALUES(spanish_name), capital = VALUES(capital),
  macro_region = VALUES(macro_region), macro_label = VALUES(macro_label),
  accent_hex = VALUES(accent_hex), accent_soft = VALUES(accent_soft),
  motif_key = VALUES(motif_key), motif_label = VALUES(motif_label),
  dops_json = VALUES(dops_json), tagline = VALUES(tagline), story = VALUES(story),
  ritual = VALUES(ritual), map_x = VALUES(map_x), map_y = VALUES(map_y), sort_order = VALUES(sort_order);

-- -----------------------------------------------------------------------------
-- 2. Catálogo Regional (56 Pratos e Iguarias Tradicionais)
-- -----------------------------------------------------------------------------
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('and-jamon-jabugo', (SELECT id FROM regions WHERE slug = 'andaluzia'), 'DISH', 'Jamón Ibérico 100% Bellota — Jabugo', 'Fatiado na Faca', 'D.O.P. Jabugo', '100g · Cura 36 meses', 24800, 30, 0, 'Fatiado manualmente na faca no dia da entrega', 'Porco 100% ibérico criado em montanera de bolotas na Serra de Huelva, cortado manualmente na faca e embalado a vácuo no dia.', 'Jabugo, Serra de Aracena (Huelva)', '36 meses em adegas naturais de serra', '22 °C — abrir 25 minutos antes de servir', 'Jerez Fino, Manzanilla ou Rioja Gran Reserva', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('and-salmorejo', (SELECT id FROM regions WHERE slug = 'andaluzia'), 'DISH', 'Salmorejo Cordobés com Lascas de Jamón', 'Prato Típico', 'Receita de Córdoba', '500 ml · Serve 2 a 3', 7800, 30, 0, NULL, 'Creme frio e aveludado de tomate maduro, pão de fermentação natural, alho suave e AOVE Picual, acompanhado de jamón picado.', 'Córdoba, Andaluzia', 'Preparo artesanal refrigerado do dia', '8 °C em tigela de barro com fio extra de azeite', 'Fino de Jerez ou Montilla-Moriles seco', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('and-aove-picual', (SELECT id FROM regions WHERE slug = 'andaluzia'), 'DISH', 'Azeite Virgem Extra Picual — Colheita Precoce', 'Despensa D.O.P.', 'Jaén · Safra Outubro', '500 ml · Acidez 0,14%', 16400, 30, 0, NULL, 'Extraído a frio de azeitonas verdes da Serra Mágina. Notas intensas de folha de tomateiro, erva fresca e picância elegante.', 'Sierra Mágina, Jaén', 'Lote numerado · Primeira prensagem', 'Cru sobre pães artesanais, salmorejo e queijos', 'Pão rústico, flor de sal de Cádis e Manchego', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('and-atum-jerez', (SELECT id FROM regions WHERE slug = 'andaluzia'), 'DISH', 'Ventresca de Atum de Almadraba & Jerez Fino', 'Conserva & Vinho', 'Barbate & D.O. Jerez', 'Lata 120g + Fino 375 ml', 21500, 30, 0, NULL, 'Atum vermelho pescado no método milenar da almadraba em azeite virgem extra, harmonizado com Jerez Fino envelhecido sob velo de flor.', 'Barbate e Jerez de la Frontera (Cádis)', 'Solera de 5 anos (Jerez) + conserva manual', 'Atum em temperatura ambiente; Jerez a 7 °C', 'Azeitonas Gordal temperadas e amêndoas Marcona', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ara-ternasco', (SELECT id FROM regions WHERE slug = 'aragao'), 'DISH', 'Paleta de Ternasco de Aragón Confitada', 'Prato Típico', 'I.G.P. Ternasco de Aragón', '650g · Pronta p/ finalizar', 19800, 30, 0, NULL, 'Paleta de cordeiro jovem confitada lentamente por 12 horas em azeite, alho e tomilho dos Pireneus, com batatas a lo pobre.', 'Zaragoza e Huesca, Aragão', 'Cozimento lento em baixa temperatura', 'Forno a 220 °C por 15 min até dourar', 'Garnacha de Campo de Borja ou Somontano', 'assets/hero.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ara-jamon-teruel', (SELECT id FROM regions WHERE slug = 'aragao'), 'DISH', 'Jamón de Teruel — Cura de Altitude', 'Fatiado na Faca', 'D.O.P. Jamón de Teruel', '100g · Fatiado na faca', 11800, 30, 0, 'Fatiado manualmente na faca no dia da entrega', 'O primeiro presunto espanhol a conquistar Denominação de Origem. Salinidade delicada, sabor doce e textura aveludada curada a 800m.', 'Província de Teruel, Aragão', '20 meses em clima frio e seco de serra', '20 °C em fatias translúcidas', 'Vinhos tintos jovens de Garnacha e pão rústico', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ara-garnacha-borja', (SELECT id FROM regions WHERE slug = 'aragao'), 'DISH', 'Garnacha Vinhas Velhas — Campo de Borja', 'Vinho & Bebida', 'D.O. Campo de Borja', '750 ml · Safra 2021', 19600, 30, 0, NULL, 'Uvas de parreiras com mais de 50 anos aos pés do Moncayo. Frutas vermelhas maduras, pimenta preta e final mineral persistente.', 'Campo de Borja, Zaragoza', '12 meses em barricas de carvalho francês', '16 °C em taça ampla', 'Ternasco assado, longaniza de Graus e queijos curados', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ast-fabada', (SELECT id FROM regions WHERE slug = 'asturias'), 'DISH', 'Fabada Asturiana com Compango Defumado', 'Prato Típico', 'I.G.P. Faba Asturiana', '750g · Serve 2 pessoas', 14600, 30, 0, NULL, 'Tradicional ensopado de fabes grandes e cremosas cozidas em fogo brando com chorizo asturiano, morcilla defumada em carvalho e lacón.', 'Oviedo e Villaviciosa, Astúrias', 'Cozimento lento artesanal, pronto para aquecer', 'Aquecer suavemente em panela sem mexer com colher', 'Sidra Natural Asturiana ou tinto leve de Mencía', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ast-cabrales', (SELECT id FROM regions WHERE slug = 'asturias'), 'DISH', 'Queijo Azul Cabrales — Maturado em Caverna', 'Queijo D.O.P.', 'D.O.P. Cabrales', '200g · Leite cru misto', 13400, 30, 0, NULL, 'Queijo azul intenso de leite de vaca, ovelha e cabra maturado nas grutas úmidas dos Picos de Europa. Textura cremosa e final picante nobre.', 'Concejo de Cabrales, Picos de Europa', '4 meses em caverna calcária natural', '20 °C acompanhado de mel de urze ou marmelada', 'Sidra de gelo, Pedro Ximénez ou pão de nozes', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ast-sidra', (SELECT id FROM regions WHERE slug = 'asturias'), 'DISH', 'Sidra Natural Asturiana — Llagar Artesanal', 'Vinho & Bebida', 'D.O.P. Sidra de Asturias', '700 ml · 100% Maçã', 9400, 30, 0, NULL, 'Fermentação espontânea de maçãs autóctones asturianas, seca, vibrante e refrescante, sem açúcares adicionados.', 'Nava e Villaviciosa, Astúrias', 'Repouso em tonéis de castanheira', '10 °C — servir em pequenos goles frescos', 'Fabada, queijos azuis, anchovas e frutos do mar', 'assets/pintxos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('bal-sobrassada', (SELECT id FROM regions WHERE slug = 'baleares'), 'DISH', 'Sobrassada de Mallorca de Porco Negro', 'Fatiado & Embutido', 'I.G.P. Sobrassada de Mallorca', '250g · Cura artesanal', 12800, 30, 0, NULL, 'Embutido macio e untuoso de porco negro maiorquino temperado com pimentón doce Tap de Cortí, ideal para comer sobre pão quente.', 'Porreres, Maiorca', 'Cura natural em tripa por 3 meses', 'Temperatura ambiente com pão tostado e mel', 'Vinhos tintos leves de Manto Negro ou Cava Rosé', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('bal-mahon', (SELECT id FROM regions WHERE slug = 'baleares'), 'DISH', 'Queijo Mahón-Menorca Semicurado', 'Queijo D.O.P.', 'D.O.P. Mahón-Menorca', '250g · Casca de pimentón', 12200, 30, 0, NULL, 'Leite de vacas que pastam sob a brisa salina de Menorca, casca esfregada com azeite e pimentón, notas amanteigadas e leve toque marinho.', 'Mahón, Ilha de Menorca', '5 meses sobre tábuas de madeira', 'Lâminas finas com fio de azeite e pimenta-do-reino', 'Brancos mediterrâneos secos ou vermute branco', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('bal-ensaimada', (SELECT id FROM regions WHERE slug = 'baleares'), 'DISH', 'Ensaïmada de Mallorca Artesanal (Sob Encomenda)', 'Doce Tradicional', 'I.G.P. Ensaïmada', '420g · Caixa octogonal', 9600, 12, 1, 'Sob encomenda — assada fresca nas manhãs de sexta e sábado (antecedência mínima de 24h)', 'Espiral aerada e delicadamente folhada de fermentação lenta de 24 horas, polvilhada com açúcar impalpável. Receita histórica de Palma.', 'Palma de Maiorca', 'Assada fresca nas manhãs de sexta e sábado', 'Temperatura ambiente com café espresso ou chocolate', 'Café de especialidade, Licor de Hierbas ou Cava', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('can-papas-mojos', (SELECT id FROM regions WHERE slug = 'canarias'), 'DISH', 'Papas Arrugadas com Dupla de Mojos Canários', 'Prato Típico', 'Tradição de Tenerife', '500g + 2 potes (180g)', 8800, 30, 0, NULL, 'Minibatatas cozidas em salmoura marinha até formar crosta salina delicada, acompanhadas de Mojo Picón vermelho e Mojo Verde de coentro.', 'Tenerife e Gran Canaria', 'Mojos artesanais em azeite virgem extra', 'Batatas quentes com os mojos em temperatura ambiente', 'Malvasía Volcánica ou cerveja artesanal clara', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('can-majorero', (SELECT id FROM regions WHERE slug = 'canarias'), 'DISH', 'Queijo Majorero Curado no Pimentón', 'Queijo D.O.P.', 'D.O.P. Queso Majorero', '250g · Leite de cabra', 12600, 30, 0, NULL, 'Produzido com leite de cabra majorera de Fuerteventura, casca rubi de pimentón e acidez limpa com final levemente amendoado.', 'Fuerteventura, Ilhas Canárias', '4 meses de maturação insular', 'Cubos ou fatias finas com mel de palma', 'Malvasía seco de Lanzarote ou vinho rosé', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('can-malvasia', (SELECT id FROM regions WHERE slug = 'canarias'), 'DISH', 'Malvasía Volcánica Seco — Lanzarote', 'Vinho & Bebida', 'D.O. Lanzarote', '750 ml · Vinhedo em lava', 25800, 30, 0, NULL, 'Branco exuberante de vinhas cultivadas em covas de cinza vulcânica (La Geria). Aromas de flor de laranjeira, cítricos e mineralidade salina.', 'La Geria, Ilha de Lanzarote', 'Estágio sobre borras finas por 4 meses', '9 °C em taça de vinho branco', 'Papas com mojo verde, frutos do mar e queijo de cabra', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cnt-anchoas', (SELECT id FROM regions WHERE slug = 'cantabria'), 'DISH', 'Anchoas do Cantábrico — Série Ouro Santoña', 'Conserva Nobre', 'Costera de Primavera · Santoña', 'Lata 110g · Filés grandes', 15800, 30, 0, NULL, 'Bocarte pescado na primavera, curado 10 meses em sal marinho e filetado manualmente sem espinhas em azeite virgem extra.', 'Santoña, Cantábria', '10 meses de maturação em salga', '16 °C com pão rústico e manteiga de nata', 'Vermute artesanal, Txakoli ou Cava Brut Nature', 'assets/conservas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cnt-quesucos', (SELECT id FROM regions WHERE slug = 'cantabria'), 'DISH', 'Queijo Picón Bejes-Tresviso & Quesucos', 'Queijo D.O.P.', 'D.O.P. Liébana', '220g · Degustação dupla', 13200, 30, 0, NULL, 'Seleção de queijos dos vales de Liébana: a delicadeza defumada do Quesuco ao lado da untuosidade azul do Picón de caverna.', 'Potes e Tresviso, Cantábria', 'Maturação artesanal de montanha', 'Temperatura ambiente com nozes e pão de centeio', 'Vinhos brancos encorpados ou Orujo de Liébana', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cnt-sobao', (SELECT id FROM regions WHERE slug = 'cantabria'), 'DISH', 'Sobao Pasiego & Quesada Artesanal', 'Doce Tradicional', 'I.G.P. Sobao Pasiego', 'Caixa 400g · 6 unidades', 8400, 30, 0, NULL, 'Bolo úmido e dourado feito com generosa manteiga de vacas pasiegas, ovos caipiras e leve toque cítrico de limão siciliano.', 'Valles Pasiegos, Cantábria', 'Forneado em lotes semanais', 'Levemente morno no café da tarde ou sobremesa', 'Café filtrado, chá preto ou vinho doce Moscatel', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('clm-manchego', (SELECT id FROM regions WHERE slug = 'castela-la-mancha'), 'DISH', 'Queijo Manchego Artesano Curado 12 Meses', 'Queijo D.O.P.', 'D.O.P. Queso Manchego', '250g · Leite cru de ovelha', 11800, 30, 0, NULL, 'Elaborado exclusivamente com leite cru de ovelha Manchega, pasta firme com cristais crocantes de tirosina e notas amanteigadas de nozes.', 'Ciudad Real, Castela-La Mancha', '12 meses em câmaras de maturação', '20 °C em cunhas finas', 'Rioja Gran Reserva, Ribera del Duero ou AOVE Picual', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('clm-pisto', (SELECT id FROM regions WHERE slug = 'castela-la-mancha'), 'DISH', 'Pisto Manchego Artesanal em Azeite Virgem Extra', 'Prato Típico', 'Horta de La Mancha', '420g · Pote de vidro', 7400, 30, 0, NULL, 'Refogado lento de pimentões verdes e vermelhos, abobrinha e tomates maduros da horta manchega em fogo brando com azeite extra virgem.', 'Almagro, Ciudad Real', 'Conserva artesanal sem aditivos', 'Morno com ovo frito caipira ou pão tostado', 'Vinhos tintos jovens de Valdepeñas ou Tempranillo', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('clm-acafrao', (SELECT id FROM regions WHERE slug = 'castela-la-mancha'), 'DISH', 'Açafrão de La Mancha em Hebras — Colheita Pura', 'Despensa D.O.P.', 'D.O.P. Azafrán de La Mancha', '2g · Estojo metálico', 14200, 30, 0, NULL, 'Estigmas puros de Crocus sativus colhidos à mão ao amanhecer e tostados suavemente. Poder aromático e cor dourada inigualáveis.', 'Consuegra, Toledo', 'Colheita recente rastreada', 'Infusionar 10 min em caldo morno antes de usar', 'Indispensável para Paellas, arrozes e caldos ibéricos', 'assets/paella.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('clm-mazapan', (SELECT id FROM regions WHERE slug = 'castela-la-mancha'), 'DISH', 'Mazapán Artesanal de Toledo — Caixa Presente', 'Doce Tradicional', 'I.G.P. Mazapán de Toledo', '250g · Amêndoa Marcona', 9800, 30, 0, NULL, 'Receita conventual de Toledo com mais de 55% de amêndoa espanhola moída e açúcar fino, levemente dourado no forno.', 'Toledo, Castela-La Mancha', 'Produção artesanal em pequenos lotes', 'Com café espresso ou vinho doce de sobremesa', 'Pedro Ximénez, Moscatel ou espresso curto', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cyl-ribera', (SELECT id FROM regions WHERE slug = 'castela-e-leao'), 'DISH', 'Ribera del Duero Crianza 2020 — Tinto Fino', 'Vinho & Bebida', 'D.O. Ribera del Duero', '750 ml · Altitude 850m', 22500, 30, 0, NULL, 'Vinhedos de altitude em Pesquera de Duero, amadurecido 14 meses em carvalho francês. Amora madura, cacau fino e frescor estruturado.', 'Pesquera de Duero, Valladolid', '14 meses em barrica + 12 meses em garrafa', '16 °C em taça Bordeaux', 'Cochinillo, Paleta de Guijuelo e queijos curados', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cyl-paleta-guijuelo', (SELECT id FROM regions WHERE slug = 'castela-e-leao'), 'DISH', 'Paleta Ibérica de Cebo de Campo — Guijuelo', 'Fatiado na Faca', 'D.O.P. Guijuelo', '100g · Fatiado na faca', 13800, 30, 0, 'Fatiado manualmente na faca no dia da entrega', 'Curada nos ventos frios de Salamanca, combina doçura delicada e infiltração aromática marcante, pronta para tábuas de aperitivo.', 'Guijuelo, Salamanca', '24 meses em secadouros naturais', '21 °C sobre prato de cerâmica', 'Ribera del Duero Crianza ou Verdejo de Rueda', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cyl-cecina', (SELECT id FROM regions WHERE slug = 'castela-e-leao'), 'DISH', 'Cecina de León Reserva Defumada em Carvalho', 'Fatiado na Faca', 'I.G.P. Cecina de León', '100g · Carne bovina curada', 11200, 30, 0, 'Fatiado manualmente na faca no dia da entrega', 'Corte nobre bovino curado por 12 meses e levemente defumado com lenha de carvalho e azinheira. Textura macia e perfume inconfundível.', 'Astorga, León', '12 meses de cura Reserva', 'Com gotas de AOVE e lascas de queijo curado', 'Tintos de Bierzo (Mencía) ou Ribera del Duero', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cyl-cochinillo', (SELECT id FROM regions WHERE slug = 'castela-e-leao'), 'DISH', 'Quarto de Cochinillo de Segóvia Confitado', 'Prato Típico', 'Marca de Garantia Segóvia', '900g · Serve 2 a 3', 26800, 30, 0, NULL, 'Leitão segoviano confitado em baixa temperatura apenas com água e sal — basta levar ao forno alto por 25 minutos para pele dourada e crocante.', 'Segóvia, Castela e Leão', 'Preparo confitado refrigerado pronto para assar', 'Forno 220 °C por 25 min · pele para cima', 'Ribera del Duero Crianza ou Reserva', 'assets/hero.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cat-fuet-vic', (SELECT id FROM regions WHERE slug = 'catalunha'), 'DISH', 'Llonganissa & Fuet Artesanal de Vic', 'Fatiado & Embutido', 'I.G.P. Llonganissa de Vic', '280g · Dupla tradicional', 10800, 30, 0, NULL, 'Salame catalão curado na névoa fria da planície de Vic, temperado apenas com sal e pimenta-do-reino em grãos, aroma limpo e textura firme.', 'Vic, Província de Barcelona', '45 dias em adega natural', 'Cortado em rodelas diagonais com Pa amb Tomàquet', 'Cava Brut Nature ou tinto jovem de Penedès', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cat-escalivada', (SELECT id FROM regions WHERE slug = 'catalunha'), 'DISH', 'Escalivada na Brasa com Anchoas de l''Escala', 'Prato Típico', 'Costa Brava · Empordà', '380g + Anchoas 80g', 13600, 30, 0, NULL, 'Berinjelas, pimentões vermelhos e cebolas doces assados diretamente na brasa e preservados em azeite, coroados com anchovas da Costa Brava.', 'L''Escala, Girona', 'Assado artesanal sobre lenha', 'Em temperatura ambiente sobre torradas de pão rústico', 'Cava Reserva Brut Nature ou branco Garnatxa Blanca', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('cat-cava', (SELECT id FROM regions WHERE slug = 'catalunha'), 'DISH', 'Cava Gran Reserva Brut Nature — Penedès', 'Vinho & Bebida', 'D.O. Cava · Método Tradicional', '750 ml · 36 meses sur lie', 21800, 30, 0, NULL, 'Xarel·lo, Macabeo e Parellada com longa autólise em garrafa. Perlage finíssimo, notas de brioche tostado, maçã verde e final seco cristalino.', 'Sant Sadurní d''Anoia, Penedès', '36 meses sobre borras em garrafa', '7 °C em taça de vinho branco ou tulipa', 'Escalivada, frutos do mar, Fuet e Jamón Bellota', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('val-kit-paella', (SELECT id FROM regions WHERE slug = 'valencia'), 'DISH', 'Kit Paella Valenciana Autêntica (Para 4 Pessoas)', 'Prato Típico', 'D.O. Arroz de Valencia', 'Arroz Bomba + Caldo + Açafrão + Garrofó', 18400, 30, 0, NULL, 'Tudo medido para preparar a legítima Paella em casa em 25 min: Arroz Bomba da Albufera, caldo artesanal de açafrão e alecrim, feijão garrofó e guia do chef.', 'Parque Natural da Albufera, Valência', 'Caldo artesanal + grãos de safra atual', 'Preparo em paellera ou frigideira larga — rende 4 porções', 'Brancos secos mediterrâneos, Rosé ou Cava Brut', 'assets/paella.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('val-fideua', (SELECT id FROM regions WHERE slug = 'valencia'), 'DISH', 'Fideuà de Gandia com Caldo de Frutos do Mar', 'Prato Típico', 'Costa de Valência · Gandia', 'Kit 4 porções + Allioli', 17200, 30, 0, NULL, 'Prima marinheira da paella feita com massa curta tostada (fideo nº 2), fumet rico de peixe de rocha e camarão, servida com allioli suave.', 'Gandia, Valência', 'Caldo marinho artesanal + massa italiana/espanhola', 'Finalizar 2 min no forno para pontas crocantes', 'Albariño, Verdejo ou Cava Reserva', 'assets/paella.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('val-turron', (SELECT id FROM regions WHERE slug = 'valencia'), 'DISH', 'Turrón Artesanal de Jijona & Alicante (Dupla)', 'Doce Tradicional', 'I.G.P. Jijona e Alicante', '2 barras · 300g total', 12400, 30, 0, NULL, 'Os dois clássicos de Alicante: o Jijona macio e cremoso de amêndoa Marcona moída com mel de alecrim, e o Alicante crocante de amêndoas inteiras.', 'Jijona, Província de Alicante', '68% de amêndoa Marcona + mel puro de flor de laranjeira', 'Em pequenos bastões ao fim do almoço', 'Fondillón de Alicante, espresso ou Cava', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ext-torta-casar', (SELECT id FROM regions WHERE slug = 'extremadura'), 'DISH', 'Queijo Torta del Casar — Cremoso de Colher', 'Queijo D.O.P.', 'D.O.P. Torta del Casar', '420g · Peça inteira', 21800, 30, 0, NULL, 'Queijo lendário de leite cru de ovelha coagulado com flor de cardo silvestre. Interior intensamente cremoso, complexo e levemente amargo.', 'Casar de Cáceres, Extremadura', '70 dias de maturação controlada', '23 °C — abrir a tampa e servir com colher e pão rústico', 'Ribera del Duero, tintos de Extremadura ou Jerez Amontillado', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ext-jamon-dehesa', (SELECT id FROM regions WHERE slug = 'extremadura'), 'DISH', 'Lomo & Jamón Ibérico Dehesa de Extremadura', 'Fatiado na Faca', 'D.O.P. Dehesa de Extremadura', '150g · Duo degustação', 22600, 30, 0, 'Fatiado manualmente na faca no dia da entrega', 'Combinação nobre de Jamón de Bellota cortado na faca com Lomo Ibérico curado em Pimentón de La Vera.', 'Jerez de los Caballeros, Badajoz', '32 meses (Jamón) e 5 meses (Lomo)', 'Temperatura ambiente em prato de pedra', 'Tintos de guarda ou branco fermentado em barrica', 'assets/jamon.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('ext-pimenton', (SELECT id FROM regions WHERE slug = 'extremadura'), 'DISH', 'Trio Pimentón de La Vera Defumado em Carvalho', 'Despensa D.O.P.', 'D.O.P. Pimentón de La Vera', '3 latas · Doce, Agridoce e Picante', 9600, 30, 0, NULL, 'Pimentões secos lentamente por 15 dias sobre lenha de carvalho e azinheira e moídos em moinho de pedra. A assinatura aromática da cozinha espanhola.', 'Comarca de La Vera, Cáceres', 'Safra atual em latas herméticas', 'Finalização de polvo à galega, batatas e caldos', 'Essencial com AOVE virgem extra e carnes grelhadas', 'assets/pulpo.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('gal-pulpo', (SELECT id FROM regions WHERE slug = 'galicia'), 'DISH', 'Polvo à Galega (Pulpo á Feira) — Pronto p/ Servir', 'Prato Típico', 'Costa da Galícia', '300g · Tentáculos fatiados', 18800, 30, 0, NULL, 'Tentáculos de polvo cozidos no ponto tradicional galego, acompanhados de sachê de Pimentón de La Vera e flor de sal marinha para finalizar em 4 minutos.', 'Ría de Arousa, Pontevedra', 'Cozido artesanalmente e embalado a vácuo', 'Quente sobre batatas cozidas com AOVE', 'Albariño D.O. Rías Baixas bem gelado', 'assets/pulpo.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('gal-mexilhoes', (SELECT id FROM regions WHERE slug = 'galicia'), 'DISH', 'Mexilhões Gigantes & Zamburiñas das Rías Baixas', 'Conserva Nobre', 'D.O.P. Mexillón de Galicia', '2 latas artesanais + Vermute', 18900, 30, 0, NULL, 'Mexilhões selecionados em escabeche suave de azeite e vieiras zamburiñas ao molho marinheiro galego, prontos para abrir e celebrar.', 'Cambados, Rías Baixas', 'Enlatado manualmente em safra', 'Temperatura ambiente com pão rústico e batatas chips', 'Albariño Rías Baixas ou Vermute Artesanal', 'assets/conservas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('gal-albarino', (SELECT id FROM regions WHERE slug = 'galicia'), 'DISH', 'Albariño Val do Salnés — D.O. Rías Baixas', 'Vinho & Bebida', 'D.O. Rías Baixas', '750 ml · Safra 2024', 21400, 30, 0, NULL, 'Branco vibrante de solos graníticos à beira-mar. Notas de pêssego branco, casca de limão, flores brancas e acidez atlântica refrescante.', 'Cambados, Val do Salnés', '5 meses sobre borras finas em inox', '9 °C em taça de branco', 'Polvo à Galega, mexilhões, queijos cremosos Tetilla', 'assets/pulpo.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('gal-tarta-santiago', (SELECT id FROM regions WHERE slug = 'galicia'), 'DISH', 'Tarta de Santiago Artesanal com Cruz de Açúcar', 'Doce Tradicional', 'I.G.P. Tarta de Santiago', '500g · Sem farinha de trigo', 11600, 30, 0, NULL, 'Torta úmida e aromática de amêndoas selecionadas, ovos caipiras, raspas de limão e canela, finalizada com o estêncil da Cruz de Santiago.', 'Santiago de Compostela, Galícia', 'Assada fresca em pequenos lotes', 'Temperatura ambiente com café ou Licor Café galego', 'Espresso, Orujo de ervas ou Moscatel', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('mad-callos', (SELECT id FROM regions WHERE slug = 'madri'), 'DISH', 'Callos a la Madrileña de Taberna Centenária', 'Prato Típico', 'Receita Castiza de Madri', '550g · Serve 2 pessoas', 13200, 30, 0, NULL, 'Clássico madrilenho cozido lentamente com chorizo defumado, morcilla, pimentón de La Vera e toque suave de cravo e louro. Caldo encorpado e sedoso.', 'Centro Histórico de Madri', 'Cozimento lento artesanal de 6 horas', 'Bem quente em caçarola de barro com pão rústico', 'Tinto Garnacha de Vinos de Madrid ou Rioja Crianza', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('mad-vermute', (SELECT id FROM regions WHERE slug = 'madri'), 'DISH', 'Vermute Rojo Artesanal de Madri + Azeitonas Campo Real', 'Vinho & Aperitivo', 'Tradição de Taberna · Madri', '750 ml + Pote 320g', 16800, 30, 0, NULL, 'Vermute macerado com 24 botânicos, losna, casca de laranja amarga e canela, acompanhado das célebres azeitonas temperadas com orégano e alho de Campo Real.', 'Madri e Campo Real', 'Macerado em tonéis de carvalho', '8 °C com gelo e casca de laranja', 'Gildas, batatas artesanais e queijos semicurados', 'assets/conservas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('mad-cocido', (SELECT id FROM regions WHERE slug = 'madri'), 'DISH', 'Kit Cocido Madrileño Completo (Grão-de-Bico & Embutidos)', 'Prato Típico', 'Tradição dos Três Vuelcos', '1,1 kg · Serve 3 a 4', 19400, 30, 0, NULL, 'O banquete de inverno madrilenho em três atos: caldo aromático com fideos, grão-de-bico manteigoso de Fuentesaúco e seleção de chorizo, morcilla e toucinho ibérico.', 'Comunidade de Madri', 'Pré-preparado artesanalmente', 'Servir tradicionalmente em 3 etapas (sopa, grãos, carnes)', 'Garnacha de San Martín de Valdeiglesias (D.O. Madrid)', 'assets/hero.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('mur-queijo-vino', (SELECT id FROM regions WHERE slug = 'murcia'), 'DISH', 'Queijo de Murcia al Vino — Banho em Monastrell', 'Queijo D.O.P.', 'D.O.P. Murcia al Vino', '250g · Leite de cabra murciana', 12900, 30, 0, NULL, 'Pasta branca, macia e amanteigada de leite de cabra murciano-granadina, com casca arroxeada banhada repetidamente em vinho tinto de Jumilla.', 'Jumilla e Yecla, Múrcia', '60 dias com banhos artesanais de vinho tinto', '18 °C em fatias médias', 'Jumilla Monastrell ou vinhos rosados secos', 'assets/manchego.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('mur-calasparra', (SELECT id FROM regions WHERE slug = 'murcia'), 'DISH', 'Arroz Bomba de Calasparra + Pimentón de Múrcia', 'Despensa D.O.P.', 'D.O.P. Calasparra', 'Saco de pano 1 kg + Lata 75g', 11400, 30, 0, NULL, 'Arroz irrigado por águas frias do rio Segura em maturação lenta — considerado por grandes chefs o grão supremo para arrozes caldosos e melosos.', 'Calasparra, Região de Múrcia', 'Safra selecionada em saco tradicional de tecido', 'Ideal para arroz caldoso de mariscos ou legumes', 'Monastrell jovem ou branco mediterrâneo', 'assets/paella.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('mur-jumilla', (SELECT id FROM regions WHERE slug = 'murcia'), 'DISH', 'Monastrell Pie Franco — D.O. Jumilla', 'Vinho & Bebida', 'D.O. Jumilla', '750 ml · Vinhas sem enxerto', 19200, 30, 0, NULL, 'Tinto mediterrâneo envolvente de vinhas velhas em pé-franco sob sol intenso. Notas de ameixa madura, alecrim selvagem e especiarias doces.', 'Altiplano de Jumilla, Múrcia', '12 meses em carvalho francês e americano', '16 °C — abrir 20 minutos antes', 'Queijo al Vino, arroz com costela e cordeiro', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('nav-piquillos', (SELECT id FROM regions WHERE slug = 'navarra'), 'DISH', 'Pimientos del Piquillo de Lodosa Recheados de Bacalhau', 'Prato Típico', 'D.O.P. Piquillo de Lodosa', '420g · 8 pimentões artesanais', 13800, 30, 0, NULL, 'Pimentões assados em lenha de faia, descascados à mão e recheados com creme sedoso de bacalhau em molho aveludado do próprio piquillo.', 'Lodosa, Ribera de Navarra', 'Elaboração artesanal pronta para aquecer', 'Aquecer suavemente na frigideira ou forno por 10 min', 'Rosado de Garnacha de Navarra ou branco seco', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('nav-espargos', (SELECT id FROM regions WHERE slug = 'navarra'), 'DISH', 'Espargos Brancos Extra Grossos de Navarra', 'Conserva Nobre', 'I.G.P. Espárrago de Navarra', 'Frasco 370g · 6 a 8 talos', 11800, 30, 0, NULL, 'Colhidos na madrugada e envasados no mesmo dia: talos tenros, sem fibras, de doçura vegetal delicada e textura que derrete na boca.', 'Tudela e Mendavia, Navarra', 'Colheita de primavera', 'Temperatura ambiente com AOVE e flor de sal', 'Rosado de sangria (Navarra) ou Cava Brut', 'assets/conservas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('nav-chistorra-pacharan', (SELECT id FROM regions WHERE slug = 'navarra'), 'DISH', 'Chistorra Artesanal & Pacharán Navarro', 'Embutido & Digestivo', 'I.G.P. Pacharán Navarro', 'Chistorra 250g + Pacharán 700 ml', 21200, 30, 0, NULL, 'Linguiça fina fresca temperada com alho e pimentón para dourar na frigideira em minutos, acompanhada do clássico licor de abrunhos silvestres.', 'Pamplona, Navarra', 'Maceração lenta de endrinas silvestres', 'Chistorra quente no pão; Pacharán a 8 °C após o jantar', 'Ideal para abrir (chistorra) e encerrar (pacharán) a noite', 'assets/pintxos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('eus-gildas', (SELECT id FROM regions WHERE slug = 'pais-basco'), 'DISH', 'Kit Gildas Donostiarras & Bonito del Norte', 'Prato Típico', 'Parte Vieja · San Sebastián', '12 Gildas montadas + Ventresca', 15600, 30, 0, NULL, 'O pintxo mais icônico de Donostia: azeitona Gordal, pimenta guindilla de Ibarra e anchova do Cantábrico no palito, com ventresca de Bonito del Norte.', 'San Sebastián (Donostia) e Ibarra', 'Montagem fresca diária em azeite virgem extra', 'Fresco direto do prato com palito tradicional', 'Txakoli de Getaria ou Rioja Alavesa', 'assets/pintxos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('eus-idiazabal', (SELECT id FROM regions WHERE slug = 'pais-basco'), 'DISH', 'Queijo Idiazabal Defumado com Marmelada Artesanal', 'Queijo D.O.P.', 'D.O.P. Idiazabal', '250g + Dulce de Membrillo 150g', 14800, 30, 0, NULL, 'Leite cru de ovelhas Latxa dos montes bascos, delicadamente defumado sobre madeira de faia e cerejeira. Notas intensas de castanha e brasa limpa.', 'Serra de Aralar, Guipúscoa', '8 meses + defumação tradicional', '20 °C com fatia de marmelada e nozes', 'Txakoli, Sidra Basca ou Rioja Alavesa', 'assets/pintxos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('eus-bacalhau', (SELECT id FROM regions WHERE slug = 'pais-basco'), 'DISH', 'Lombo de Bacalhau ao Pil-Pil — Pronto p/ Finalizar', 'Prato Típico', 'Receita Tradicional de Bilbao', '420g · Serve 2 pessoas', 19600, 30, 0, NULL, 'Lombo alto de Gadus morhua dessalgado no ponto e confitado com lâminas de alho, guindilla suave e emulsão aveludada de azeite virgem extra.', 'Bilbao, Biscaia', 'Preparo refrigerado artesanal', 'Aquecer suavemente em caçarola por 8 min em fogo baixo', 'Txakoli fermentado em barrica ou Rioja Branco', 'assets/pulpo.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('eus-txakoli', (SELECT id FROM regions WHERE slug = 'pais-basco'), 'DISH', 'Txakoli de Getaria — D.O. Getariako Txakolina', 'Vinho & Bebida', 'D.O. Getariako Txakolina', '750 ml · Uva Hondarrabi Zuri', 19800, 30, 0, NULL, 'Branco atlântico de acidez elétrica, toque sutil de agulha natural e aromas de maçã verde, lima e brisa oceânica de Getaria.', 'Getaria, Costa Basca', 'Jovem de safra sobre borras finas', '8 °C vertido levemente do alto no copo', 'Gildas, Idiazabal, anchovas e bacalhau', 'assets/pintxos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('rio-gran-reserva', (SELECT id FROM regions WHERE slug = 'la-rioja'), 'DISH', 'Rioja Gran Reserva 2016 — Tempranillo', 'Vinho & Bebida', 'D.O.Ca. Rioja', '750 ml · Rioja Alta', 31000, 30, 0, NULL, 'Vinhedos velhos de Haro com 24 meses em carvalho americano e 36 meses em garrafa. Taninos sedosos, fruta madura, cedro e elegância atemporal.', 'Haro, Rioja Alta', '24 meses em barrica + 36 meses em garrafa', '17 °C — decantar 30 minutos', 'Jamón 100% Bellota, cordeiro e Manchego 12 meses', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('rio-patatas', (SELECT id FROM regions WHERE slug = 'la-rioja'), 'DISH', 'Patatas a la Riojana com Chorizo I.G.P.', 'Prato Típico', 'I.G.P. Chorizo Riojano', '650g · Serve 2 pessoas', 11800, 30, 0, NULL, 'O guisado mais amado de La Rioja: batatas quebradas à mão cozidas com chorizo artesanal em ferradura, pimentón e louro em caldo espesso e perfumado.', 'Logroño, La Rioja', 'Preparo artesanal refrigerado', 'Bem quente em prato fundo com pão de casca grossa', 'Rioja Crianza ou Gran Reserva', 'assets/tapas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('rio-pimientos-peras', (SELECT id FROM regions WHERE slug = 'la-rioja'), 'DISH', 'Pimientos Riojanos na Lenha & Peras al Vino', 'Conserva & Sobremesa', 'I.G.P. Pimiento Riojano', '2 frascos · 350g cada', 12600, 30, 0, NULL, 'Dupla clássica de Logroño: tiras de pimentões assados em lenha de videira para abrir o apetite e peras cozidas em vinho tinto de Rioja com canela para a sobremesa.', 'Nájera e Rincón de Soto, La Rioja', 'Conserva artesanal de safra', 'Pimentões com azeite e alho; Peras geladas com creme fresco', 'Rioja Reserva para ambos os momentos', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  region_id = VALUES(region_id), name = VALUES(name), category = VALUES(category),
  dop_label = VALUES(dop_label), weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  is_made_to_order = VALUES(is_made_to_order), availability_note = VALUES(availability_note),
  short_desc = VALUES(short_desc), origin_detail = VALUES(origin_detail), aging_detail = VALUES(aging_detail),
  serving_detail = VALUES(serving_detail), pairing_detail = VALUES(pairing_detail), image_url = VALUES(image_url);

-- -----------------------------------------------------------------------------
-- 3. Caixas Presente e Planos do Clube La Mesa (3 Itens Extras)
-- -----------------------------------------------------------------------------
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('caixa-noite-lago', NULL, 'BOX', 'Caixa Degustação “Noite no Lago”', 'Caixa Degustação', 'Curadoria Nacional · 5 Regiões', 'Caixa madeira + 5 regiões', 59000, 15, 0, 'Montada no dia em caixa de madeira natural com linho cru e cartão', 'Seleção assinatura do O Espanhol para presentear em Brasília: Jamón 100% Bellota, Rioja Gran Reserva, Manchego 12 meses, AOVE Picual e azeitonas Gordal.', 'Seleção O Espanhol · Brasília', 'Montagem artesanal sob pedido', 'Serve de 4 a 6 convidados', 'Pronta para presentear ou abrir direto à mesa', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), category = VALUES(category), dop_label = VALUES(dop_label),
  weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  availability_note = VALUES(availability_note), short_desc = VALUES(short_desc), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('clube-tertulia', NULL, 'CLUB_PLAN', 'Clube La Mesa — Plano Tertúlia (1º mês)', 'Clube La Mesa', 'Volta à Espanha em 17 Meses', '1 Comunidade Autônoma / mês · Frete incluso', 39000, 999, 0, 'Entrega mensal toda primeira sexta-feira do mês no DF (frete incluso)', 'Assinatura mensal dedicada a uma Comunidade Autônoma diferente por mês, com prato/embutido fatiado na faca, rótulo regional e caderno editorial.', '17 Comunidades Autônomas', 'Curadoria mensal inédita', 'Ideal para 2 a 4 pessoas', 'Inclui notas de degustação e ritual regional', 'assets/cestas.jpg', 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), category = VALUES(category), dop_label = VALUES(dop_label),
  weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  availability_note = VALUES(availability_note), short_desc = VALUES(short_desc), image_url = VALUES(image_url);
INSERT INTO products (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty, is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
VALUES ('clube-gran-reserva', NULL, 'CLUB_PLAN', 'Clube La Mesa — Plano Gran Reserva (1º mês)', 'Clube La Mesa', 'Lotes Raros & Degustações Privadas', 'Lotes raros regionais · Entrega expressa', 68000, 999, 0, 'Entrega prioritária mensal no DF + convite para degustações no Atelier Asa Sul', 'Edição estendida mensal da Comunidade Autônoma homenageada: Jamón 100% Bellota, prato típico principal, queijo D.O.P. e dois rótulos de guarda.', '17 Comunidades Autônomas', 'Safras limitadas e lotes numerados', 'Ideal para 4 a 6 pessoas', 'Concierge prioritário e entrega expressa em 2h', 'assets/vinhos.jpg', 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), category = VALUES(category), dop_label = VALUES(dop_label),
  weight_label = VALUES(weight_label), price_cents = VALUES(price_cents),
  availability_note = VALUES(availability_note), short_desc = VALUES(short_desc), image_url = VALUES(image_url);

-- -----------------------------------------------------------------------------
-- 4. Zonas de Entrega Refrigerada no Distrito Federal (8 Regiões)
-- -----------------------------------------------------------------------------
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('lago-sul', 'Lago Sul', 'Até 2h30', 2400, 35000, 'Rota prioritária refrigerada com saída às 11h, 15h e 18h30. Ideal para jantares e recepções à beira-lago.', 1, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('asa-sul', 'Asa Sul', 'Até 1h45', 1600, 35000, 'Proximidade imediata do nosso Atelier na CLS 405. Retirada sem taxa disponível no mesmo dia.', 1, 2)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('asa-norte', 'Asa Norte', 'Até 2h15', 1800, 35000, 'Entregas climatizadas em todas as superquadras e comerciais da Asa Norte até às 20h.', 1, 3)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('sudoeste', 'Sudoeste / Octogonal', 'Até 2h00', 1800, 35000, 'Rota expressa saindo do Plano Piloto com embalagem térmica vedada.', 1, 4)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('noroeste', 'Noroeste', 'Até 2h15', 2000, 35000, 'Entrega agendada ou expressa no mesmo dia para pedidos confirmados até 18h.', 1, 5)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('lago-norte', 'Lago Norte', 'Até 2h45', 2600, 35000, 'Rota refrigerada cobrindo toda a Península dos Ministros e quadras do Lago Norte.', 1, 6)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('park-way', 'Park Way', 'Até 3h00', 2800, 40000, 'Entrega refrigerada programada para condomínios do Park Way com confirmação prévia pelo Concierge.', 1, 7)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);
INSERT INTO delivery_zones (slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note, is_active, sort_order)
VALUES ('aguas-claras', 'Águas Claras', 'Até 3h00', 2600, 40000, 'Duas janelas diárias refrigeradas (tarde e noite) com controle rigoroso de temperatura.', 1, 8)
ON DUPLICATE KEY UPDATE
  name = VALUES(name), eta_label = VALUES(eta_label), fee_cents = VALUES(fee_cents),
  free_shipping_min_cents = VALUES(free_shipping_min_cents), delivery_note = VALUES(delivery_note), sort_order = VALUES(sort_order);

-- -----------------------------------------------------------------------------
-- 5. Rotas do Sommelier (4 Rotas Regionais com 8% de Cortesia no Servidor)
-- -----------------------------------------------------------------------------
INSERT INTO sommelier_routes (slug, title, subtitle, curator_note, discount_bps, rules_json, is_active, sort_order)
VALUES ('sul', 'Rota do Sul & Dehesa', 'Andaluzia & Extremadura: Jabugo, Salmorejo e Torta del Casar', '“Uma travessia ensolarada entre Andaluzia e Extremadura: comece com Salmorejo Cordobés e Fino de Jerez, siga para o Jamón 100% Bellota de Jabugo e encerre mergulhando pão rústico na cremosa Torta del Casar.”', 800, '[{"sku":"and-jamon-jabugo","per_guests":3,"min_qty":1},{"sku":"and-salmorejo","per_guests":3,"min_qty":1},{"sku":"ext-torta-casar","fixed_qty":1},{"sku":"and-atum-jerez","per_guests":4,"min_qty":1}]', 1, 1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), curator_note = VALUES(curator_note),
  discount_bps = VALUES(discount_bps), rules_json = VALUES(rules_json), sort_order = VALUES(sort_order);
INSERT INTO sommelier_routes (slug, title, subtitle, curator_note, discount_bps, rules_json, is_active, sort_order)
VALUES ('norte', 'Rota Atlântica — Norte Verde', 'Galícia, País Basco & Astúrias: Polvo, Gildas e Albariño', '“O frescor oceânico da Galícia, País Basco e Astúrias: abra com Gildas Donostiarras e Txakoli gelado, sirva o Polvo à Feira sobre tábuas de madeira com Albariño e feche com o Idiazabal defumado.”', 800, '[{"sku":"gal-pulpo","per_guests":3,"min_qty":1},{"sku":"eus-gildas","per_guests":4,"min_qty":1},{"sku":"eus-idiazabal","fixed_qty":1},{"sku":"gal-albarino","per_guests":4,"min_qty":1},{"sku":"ast-sidra","per_guests":6,"min_qty":1}]', 1, 2)
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), curator_note = VALUES(curator_note),
  discount_bps = VALUES(discount_bps), rules_json = VALUES(rules_json), sort_order = VALUES(sort_order);
INSERT INTO sommelier_routes (slug, title, subtitle, curator_note, discount_bps, rules_json, is_active, sort_order)
VALUES ('mediterraneo', 'Rota Mediterrânea & Ilhas', 'Valência, Catalunha & Baleares: Paella, Cava e Sobrassada', '“Almoço luminoso do Levante às Baleares: Escalivada catalã e Sobrassada de Mallorca com Cava Brut Nature enquanto a Paella Valenciana descansa por 5 minutos, fechando com Turrón de Jijona.”', 800, '[{"sku":"val-kit-paella","per_guests":4,"min_qty":1},{"sku":"cat-escalivada","per_guests":4,"min_qty":1},{"sku":"bal-sobrassada","fixed_qty":1},{"sku":"cat-cava","per_guests":4,"min_qty":1},{"sku":"val-turron","fixed_qty":1}]', 1, 3)
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), curator_note = VALUES(curator_note),
  discount_bps = VALUES(discount_bps), rules_json = VALUES(rules_json), sort_order = VALUES(sort_order);
INSERT INTO sommelier_routes (slug, title, subtitle, curator_note, discount_bps, rules_json, is_active, sort_order)
VALUES ('meseta', 'Rota da Meseta Real & La Rioja', 'Madri, La Rioja & Castelas: Rioja Gran Reserva e Manchego', '“Clássicos solenes do interior espanhol: Vermute de Madri e azeitonas Campo Real no aperitivo, Queijo Manchego 12 meses, Paleta de Guijuelo e o Rioja Gran Reserva 2016 decantado.”', 800, '[{"sku":"rio-gran-reserva","per_guests":4,"min_qty":1},{"sku":"clm-manchego","per_guests":4,"min_qty":1},{"sku":"cyl-paleta-guijuelo","per_guests":3,"min_qty":1},{"sku":"mad-vermute","fixed_qty":1},{"sku":"rio-patatas","per_guests":4,"min_qty":1}]', 1, 4)
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), curator_note = VALUES(curator_note),
  discount_bps = VALUES(discount_bps), rules_json = VALUES(rules_json), sort_order = VALUES(sort_order);

COMMIT;

-- -----------------------------------------------------------------------------
-- 6. Primeiro Administrador (ADMIN)
-- Por segurança, NÃO incluímos senha padrão em texto ou hash público.
-- Gere o hash via PHP 8.x no terminal (ou SSH da KingHost):
--   php -r "echo password_hash('SUA_SENHA_FORTE_AQUI', PASSWORD_ARGON2ID), PHP_EOL;"
-- Em seguida, execute no MySQL:
--   INSERT INTO staff_users (full_name, email, password_hash, role, is_active)
--   VALUES ('Direção O Espanhol', 'admin@oespanhol.com.br', '<HASH_GERADO>', 'ADMIN', 1);
-- -----------------------------------------------------------------------------