# Prompt lab: experiment.json

2026-09-29.

| Model | Setup | Judged | Words per reply | Words per sentence | Quoted words (max) | Invented | No-op | Caught | First token | Reply starts | Tokens in / out |
| -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| gpt-5.4-nano | app_v5 mixed_portuguese cefr_level=B1 reply_level=B1 | B1 | 33 | 8.6 | 1.8 (5) | 1 | 3 | 5 / 8 | 0.8 s | 1.45 s | 4594 / 1102 |
| gpt-6-luna | app_v5 mixed_portuguese cefr_level=B1 reply_level=B1 | B1 | 25 | 7.3 | 2.4 (5) | 0 | 0 | 8 / 8 | 1.0 s | 1.94 s | 4511 / 1072 |
| gpt-5.4-nano | v6 mixed_portuguese cefr_level=B1 reply_level=B1 | B1 | 25 | 7.8 | 1.7 (5) | 1 | 0 | 7 / 8 | 0.89 s | 1.66 s | 4992 / 1039 |
| gpt-6-luna | v6 mixed_portuguese cefr_level=B1 reply_level=B1 | B1 | 24 | 7.9 | 2.5 (5) | 0 | 0 | 8 / 8 | 1.14 s | 1.95 s | 4953 / 1065 |
| gpt-5.4-nano | app_v5 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES | B1 | 36 | 9.9 | 2.3 (6) | 0 | 0 | 5 / 7 | 0.92 s | 1.4 s | 4773 / 993 |
| gpt-6-luna | app_v5 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES | B2 | 25 | 7.8 | 1.4 (3) | 0 | 0 | 7 / 7 | 1.01 s | 1.71 s | 4636 / 966 |
| gpt-5.4-nano | v6 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES | B2 | 30 | 8.3 | 1.6 (3) | 0 | 1 | 6 / 7 | 0.81 s | 1.38 s | 5235 / 1018 |
| gpt-6-luna | v6 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES | B1 | 24 | 8.1 | 1.5 (4) | 0 | 0 | 7 / 7 | 0.96 s | 1.82 s | 5145 / 1013 |
| gpt-5.4-nano | v6 spanish cefr_level=C1 reply_level=C2 target_language=Spanish (Spain) language_code=es-ES | C1 | 52 | 17.5 | 1.9 (4) | 0 | 1 | 6 / 7 | 0.77 s | 1.39 s | 5417 / 1294 |
| gpt-6-luna | v6 spanish cefr_level=C1 reply_level=C2 target_language=Spanish (Spain) language_code=es-ES | B2 | 49 | 16.3 | 1.2 (2) | 0 | 0 | 7 / 7 | 1.14 s | 1.94 s | 5358 / 1333 |

## Replies

### gpt-5.4-nano | app_v5 mixed_portuguese cefr_level=B1 reply_level=B1

- User: Ele precisa de supervisão claro. Quer descobrir todo mundo e vai caminhar sem dúvida verso o perigolos (expect: verso, perigolos)
  - Fix: supervisão claro -> supervisão, claro; todo mundo -> todo mundo; perigolos -> perigo
  - Tutor: Entendi. Essa frase ficou bem preocupante, porque “perigo” aparece no final. Você quer dizer que ele vai para um lugar perigoso ou que ele vai causar perigo? Eu acho importante colocar mais contexto para ficar claro.
- User: Ontem ele subiu na mesa e quase caiu, ma por sorte eu estava vicino. (expect: ma, vicino)
  - Fix: ma -> mas; perto -> perto
  - Tutor: Nossa, que susto! Fico feliz que você estava perto para ajudar. Você acha que ele fez isso por curiosidade ou por brincadeira?
- User: Minha esposa diz que eu sou muito preocupado, pero eu acho que é normal com o primeiro filho. (expect: pero)
  - Fix: pero -> mas; preocupado -> preocupado
  - Tutor: Eu entendo você. Com o primeiro filho, a gente fica mesmo mais atento. Eu também fico preocupado quando algo pode dar errado, mas tento respirar fundo. Você está mais preocupado com a saúde ou com a segurança?
- User: Na semana que vem vamos levar ele no parque para jogar com a ball, se o tempo é bom. (expect: ball, é bom)
  - Fix: no parque -> ao parque; a ball -> a bola; se o tempo é bom -> se o tempo estiver bom
  - Tutor: Que legal! Levar ele ao parque costuma fazer bem. Eu gosto quando o tempo está agradável, porque dá para relaxar também. Vocês vão de manhã ou à tarde?
- User: Ele já sabe dizer algumas palavras, como mamãe, papai e acqua. (expect: acqua)
  - Fix: (none)
  - Tutor: Que fofo! Quando ele fala “mamãe” e “papai”, dá uma alegria enorme. “Água” é a forma certa em português, mas entendo que ele ainda pode falar “acqua”. Você quer ensinar mais palavras, ou prefere deixar ele aprender no dia a dia?

### gpt-6-luna | app_v5 mixed_portuguese cefr_level=B1 reply_level=B1

- User: Ele precisa de supervisão claro. Quer descobrir todo mundo e vai caminhar sem dúvida verso o perigolos (expect: verso, perigolos)
  - Fix: supervisão claro -> supervisão, claro; todo mundo -> tudo; verso o perigolos -> em direção ao perigo
  - Tutor: Parece que ele é muito curioso e não percebe os riscos. Eu também já segui uma trilha sem prestar atenção e me perdi por alguns minutos. O que ele quer descobrir?
- User: Ontem ele subiu na mesa e quase caiu, ma por sorte eu estava vicino. (expect: ma, vicino)
  - Fix: ma -> mas; vicino -> perto
  - Tutor: Que susto! Ainda bem que você estava por perto. Ele costuma subir nos móveis da casa?
- User: Minha esposa diz que eu sou muito preocupado, pero eu acho que é normal com o primeiro filho. (expect: pero)
  - Fix: pero -> mas
  - Tutor: Entendo! Com o primeiro filho, é fácil ficar de olho em tudo. Eu também seria cuidadoso, mas tentaria deixar a criança explorar com segurança. O que mais preocupa você?
- User: Na semana que vem vamos levar ele no parque para jogar com a ball, se o tempo é bom. (expect: ball, é bom)
  - Fix: levar ele no parque -> levá-lo ao parque; jogar com a ball -> brincar com a bola; se o tempo é bom -> se o tempo estiver bom
  - Tutor: Que bom! Um parque é ótimo para ele gastar energia, e uma bola pode render muita diversão. Espero que o tempo colabore. Vocês costumam levar brinquedos para o parque?
- User: Ele já sabe dizer algumas palavras, como mamãe, papai e acqua. (expect: acqua)
  - Fix: acqua -> água
  - Tutor: Que gracinha! É muito especial ouvir as primeiras palavras do filho. Qual foi a primeira palavra que ele disse?

### gpt-5.4-nano | v6 mixed_portuguese cefr_level=B1 reply_level=B1

- User: Ele precisa de supervisão claro. Quer descobrir todo mundo e vai caminhar sem dúvida verso o perigolos (expect: verso, perigolos)
  - Fix: descobrir -> conhecer; sem dúvida verso -> sem dúvida em direção; perigolos -> perigo
  - Tutor: Entendi. Eu acho que “supervisão” ajuda muito em situações de risco. Você está falando de uma criança, ou de alguém que precisa de atenção no trabalho?
- User: Ontem ele subiu na mesa e quase caiu, ma por sorte eu estava vicino. (expect: ma, vicino)
  - Fix: ma -> mas; porde -> perto
  - Tutor: Nossa, que susto! Eu também fico atento quando vejo alguém subindo em lugar alto. Você conseguiu ajudá-lo a ficar mais seguro depois disso?
- User: Minha esposa diz que eu sou muito preocupado, pero eu acho que é normal com o primeiro filho. (expect: pero)
  - Fix: pero -> mas
  - Tutor: Entendo você. Com o primeiro filho, a gente fica mesmo mais atento. Eu também fiquei assim quando meu sobrinho nasceu. Você costuma se preocupar mais com segurança ou com saúde?
- User: Na semana que vem vamos levar ele no parque para jogar com a ball, se o tempo é bom. (expect: ball, é bom)
  - Fix: no parque -> ao parque; ball -> bola; se o tempo é bom -> se o tempo estiver bom
  - Tutor: Que legal! Eu gosto dessa ideia de parque, porque as crianças gastam energia. Vocês vão de manhã ou à tarde?
- User: Ele já sabe dizer algumas palavras, como mamãe, papai e acqua. (expect: acqua)
  - Fix: acqua -> água
  - Tutor: Que fofo! Quando ele fala “mamãe” e “papai”, vocês respondem muito? Eu acho legal repetir as palavras com calma, porque ajuda ele a aprender rápido.

### gpt-6-luna | v6 mixed_portuguese cefr_level=B1 reply_level=B1

- User: Ele precisa de supervisão claro. Quer descobrir todo mundo e vai caminhar sem dúvida verso o perigolos (expect: verso, perigolos)
  - Fix: supervisão claro -> supervisão, claro; descobrir todo mundo -> descobrir tudo sobre todo mundo; verso o perigolos -> em direção ao perigo
  - Tutor: Parece que ele é muito curioso e não percebe os riscos. Eu ficaria preocupado com essa caminhada. O que ele quer descobrir?
- User: Ontem ele subiu na mesa e quase caiu, ma por sorte eu estava vicino. (expect: ma, vicino)
  - Fix: ma -> mas; vicino -> perto
  - Tutor: Ainda bem que você estava por perto! Crianças e animais podem ser muito rápidos quando estão curiosos. Você conseguiu tirá-lo da mesa com facilidade?
- User: Minha esposa diz que eu sou muito preocupado, pero eu acho que é normal com o primeiro filho. (expect: pero)
  - Fix: pero -> mas
  - Tutor: Acho bem normal se preocupar, ainda mais com o primeiro filho. Eu também ficaria de olho em cada passo! Como ele se chama?
- User: Na semana que vem vamos levar ele no parque para jogar com a ball, se o tempo é bom. (expect: ball, é bom)
  - Fix: levar ele no parque -> levá-lo ao parque; jogar com a ball -> brincar com a bola; se o tempo é bom -> se o tempo estiver bom
  - Tutor: Que bom, um passeio no parque pode ser ótimo para ele gastar energia. Eu gosto de levar uma bola e fazer um piquenique simples. Vocês costumam ir a esse parque?
- User: Ele já sabe dizer algumas palavras, como mamãe, papai e acqua. (expect: acqua)
  - Fix: acqua -> água
  - Tutor: Que gracinha! É muito especial ouvir as primeiras palavras do filho. Qual foi a primeira palavra que ele disse?

### gpt-5.4-nano | app_v5 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES

- User: ¡Hola! Este fin de semana he ido a la montaña con mis amigos, pero hacía mucho frío y no he portado la chaqueta. (expect: portado)
  - Fix: (none)
  - Tutor: ¡Qué bien! Ir a la montaña con amigos suena genial, aunque haga frío. La próxima vez, seguro que te acuerdas de la chaqueta. ¿Qué hiciste allí: senderismo, nieve o solo estar en el pueblo?
- User: Por la noche cenamos en un restaurante muy carino, la comida era buenísima pero el cuenta fue muy alta. (expect: carino, el cuenta)
  - Fix: muy carino -> muy caro; el cuenta -> la cuenta; pero el cuenta fue muy alta -> pero la cuenta fue muy alta
  - Tutor: ¡Qué bien que la comida te gustara tanto! A mí me pasa igual: si el sitio es bueno, vuelvo aunque sea caro. ¿Recuerdas qué pedisteis: algo de carne, pescado o pasta?
- User: Mañana tengo que trabajar, pero antes quiero hacer un poco de workout en el parque. (expect: workout)
  - Fix: (none)
  - Tutor: ¡Perfecto! Un poco de workout antes de trabajar te va a dar energía. Yo a veces hago estiramientos en el parque, y luego voy al trabajo con mejor humor. ¿Qué tipo de ejercicio harás: correr, pesas o ejercicios con el cuerpo?
- User: Si tendría más tiempo, aprendería a cocinar platos españoles, sobretodo la paella. (expect: tendría, sobretodo)
  - Fix: Si tendría -> Si tuviera; sobretodo -> sobre todo
  - Tutor: ¡Qué buena idea! La paella es de esas recetas que dan orgullo cuando sale bien. Si tuvieras tiempo, ¿la aprenderías con una receta tradicional o con algún vídeo?
- User: Mi hermana dice que la paella de Valencia es la mejor, pero yo no la he probado ancora. (expect: ancora)
  - Fix: ancora -> todavía
  - Tutor: ¡Qué bien! Si la pruebas, seguro que entiendes por qué a tu hermana le encanta. Yo la primera vez la probé en una fiesta del barrio, y me sorprendió el sabor. ¿Vas a probarla pronto o tienes que esperar a un viaje a Valencia?

### gpt-6-luna | app_v5 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES

- User: ¡Hola! Este fin de semana he ido a la montaña con mis amigos, pero hacía mucho frío y no he portado la chaqueta. (expect: portado)
  - Fix: portado la chaqueta -> llevado la chaqueta
  - Tutor: ¡Vaya, qué frío! A mí también se me olvida la chaqueta a veces. ¿Pudiste entrar en algún sitio para calentarte?
- User: Por la noche cenamos en un restaurante muy carino, la comida era buenísima pero el cuenta fue muy alta. (expect: carino, el cuenta)
  - Fix: carino -> caro; el cuenta -> la cuenta
  - Tutor: ¡Qué pena pagar tanto, aunque la comida estuviera buenísima! A mí me pasó algo parecido en un restaurante junto al mar. ¿Qué plato pedisteis?
- User: Mañana tengo que trabajar, pero antes quiero hacer un poco de workout en el parque. (expect: workout)
  - Fix: workout -> ejercicio
  - Tutor: ¡Buena idea! Hacer ejercicio por la mañana ayuda a empezar el día con energía. Yo prefiero salir a correr cuando hace buen tiempo. ¿Qué tipo de ejercicio vas a hacer?
- User: Si tendría más tiempo, aprendería a cocinar platos españoles, sobretodo la paella. (expect: tendría, sobretodo)
  - Fix: tendría -> tuviera; sobretodo -> sobre todo
  - Tutor: ¡La paella es una elección estupenda! Me encanta, aunque nunca me sale tan buena como la de mi madre. ¿Qué tipo de paella te gustaría aprender a preparar?
- User: Mi hermana dice que la paella de Valencia es la mejor, pero yo no la he probado ancora. (expect: ancora)
  - Fix: ancora -> todavía
  - Tutor: ¡Pues tienes que probarla algún día! La paella valenciana tradicional lleva pollo, conejo y judías verdes. ¿Te gustaría cocinarla con tu hermana?

### gpt-5.4-nano | v6 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES

- User: ¡Hola! Este fin de semana he ido a la montaña con mis amigos, pero hacía mucho frío y no he portado la chaqueta. (expect: portado)
  - Fix: (none)
  - Tutor: ¡Qué bien! Ir a la montaña con amigos suena genial. Si hacía mucho frío, es normal que te arrepintieras de no llevar la chaqueta. ¿Te lo pasaste bien allí, o el frío te fastidió bastante?
- User: Por la noche cenamos en un restaurante muy carino, la comida era buenísima pero el cuenta fue muy alta. (expect: carino, el cuenta)
  - Fix: carino -> caro; el cuenta -> la cuenta; fue muy alta -> fue muy alta
  - Tutor: ¡Uf, ya te entiendo! A veces el sitio es buenísimo, pero la cuenta duele. ¿Recuerdas qué pedisteis para cenar?
- User: Mañana tengo que trabajar, pero antes quiero hacer un poco de workout en el parque. (expect: workout)
  - Fix: workout -> ejercicio
  - Tutor: ¡Genial! Hacer ejercicio antes de trabajar te deja con más energía. Si quieres, puedes hacerlo suave, como caminar rápido o estirar. ¿Qué tipo de ejercicio harás: correr, pesas o algo de estiramientos?
- User: Si tendría más tiempo, aprendería a cocinar platos españoles, sobretodo la paella. (expect: tendría, sobretodo)
  - Fix: Si tendría -> Si tuviera; sobretodo -> sobre todo
  - Tutor: ¡Qué plan tan bueno! La paella requiere paciencia, pero es muy gratificante. Si pudieras elegir, ¿la aprenderías con alguien de tu familia o en un curso?
- User: Mi hermana dice que la paella de Valencia es la mejor, pero yo no la he probado ancora. (expect: ancora)
  - Fix: ancora -> todavía
  - Tutor: ¡Qué bien! Si tu hermana dice que es la mejor, seguro que está riquísima. Yo la probé una vez en una fiesta y me encantó el sabor del arroz. ¿Cuándo crees que podrás probar una paella de Valencia?

### gpt-6-luna | v6 spanish cefr_level=B1 reply_level=B1 target_language=Spanish (Spain) language_code=es-ES

- User: ¡Hola! Este fin de semana he ido a la montaña con mis amigos, pero hacía mucho frío y no he portado la chaqueta. (expect: portado)
  - Fix: portado -> llevado
  - Tutor: ¡Vaya, qué frío! A mí también se me olvida la chaqueta a veces, y luego me arrepiento. ¿Pudiste entrar en algún sitio para calentarte?
- User: Por la noche cenamos en un restaurante muy carino, la comida era buenísima pero el cuenta fue muy alta. (expect: carino, el cuenta)
  - Fix: carino -> caro; la comida era buenísima -> la comida estaba buenísima; el cuenta -> la cuenta
  - Tutor: ¡Qué pena que la cuenta fuera tan alta! A veces merece la pena pagar un poco más por una comida memorable. ¿Qué plato pediste?
- User: Mañana tengo que trabajar, pero antes quiero hacer un poco de workout en el parque. (expect: workout)
  - Fix: workout -> ejercicio
  - Tutor: ¡Buena idea! A mí me gusta hacer ejercicio al aire libre, aunque por la mañana me cuesta arrancar. ¿Qué tipo de ejercicio vas a hacer?
- User: Si tendría más tiempo, aprendería a cocinar platos españoles, sobretodo la paella. (expect: tendría, sobretodo)
  - Fix: tendría -> tuviera; sobretodo -> sobre todo
  - Tutor: ¡La paella es un plato estupendo para aprender! Yo la preparé una vez con amigos y nos quedó bastante bien. ¿Qué tipo de paella te gustaría hacer?
- User: Mi hermana dice que la paella de Valencia es la mejor, pero yo no la he probado ancora. (expect: ancora)
  - Fix: ancora -> todavía
  - Tutor: ¡Pues tienes que probarla algún día! La paella valenciana suele llevar pollo, conejo y judías verdes. ¿Te gustaría prepararla en casa?

### gpt-5.4-nano | v6 spanish cefr_level=C1 reply_level=C2 target_language=Spanish (Spain) language_code=es-ES

- User: ¡Hola! Este fin de semana he ido a la montaña con mis amigos, pero hacía mucho frío y no he portado la chaqueta. (expect: portado)
  - Fix: (none)
  - Tutor: ¡Qué buena escapada! Eso pasa mucho: uno se confía en la previsión y luego el frío te da un aviso serio. La próxima vez, aunque no la uses, una chaqueta ligera plegable siempre salva la situación. ¿Qué fue lo mejor del plan: el paisaje, alguna actividad concreta o simplemente el ambiente con tus amigos?
- User: Por la noche cenamos en un restaurante muy carino, la comida era buenísima pero el cuenta fue muy alta. (expect: carino, el cuenta)
  - Fix: muy carino -> muy caro; el cuenta -> la cuenta; la comida era buenísima -> la comida era buenísima
  - Tutor: Por la noche cenamos en un restaurante muy caro: la comida era buenísima, pero la cuenta fue muy alta. A mí me pasa justo al revés: me dejo llevar por el menú y luego me llevo el susto en el momento de pagar. ¿Fue una cena “de capricho” o más bien un sitio que os recomendaron y esperabais que no se disparara tanto?
- User: Mañana tengo que trabajar, pero antes quiero hacer un poco de workout en el parque. (expect: workout)
  - Fix: workout -> entrenamiento
  - Tutor: ¡Buena forma de empezar el día! Si vas a entrenar en el parque, ¿qué harás: fuerza con calistenia, algo de cardio o una mezcla? Yo suelo hacer un circuito corto y, si el tiempo acompaña, remato con estiramientos para no llegar rígido al trabajo.
- User: Si tendría más tiempo, aprendería a cocinar platos españoles, sobretodo la paella. (expect: tendría, sobretodo)
  - Fix: Si tendría -> Si tuviera; sobretodo -> sobre todo
  - Tutor: Me gusta el matiz: suena a una intención que te ronda pero que hoy no puedes ejecutar. La paella, además, tiene su truco—¿la harías de marisco, de pollo y conejo, o te tirarías a una versión más atrevida?
- User: Mi hermana dice que la paella de Valencia es la mejor, pero yo no la he probado ancora. (expect: ancora)
  - Fix: ancora -> todavía
  - Tutor: Tiene toda la pinta de ser una de esas discusiones gastronómicas que no se resuelven con argumentos, sino con una buena cata. Yo, por ejemplo, siempre acabo defendiendo la paella de la casa… hasta que alguien me enseña una versión distinta y me deja sin palabras. ¿Crees que tu hermana se la hace ella o va a pedirla a algún sitio en concreto?

### gpt-6-luna | v6 spanish cefr_level=C1 reply_level=C2 target_language=Spanish (Spain) language_code=es-ES

- User: ¡Hola! Este fin de semana he ido a la montaña con mis amigos, pero hacía mucho frío y no he portado la chaqueta. (expect: portado)
  - Fix: portado -> llevado
  - Tutor: ¡Vaya, qué faena! El frío en la montaña se mete hasta los huesos, y más si te pilla sin chaqueta. A mí me pasó una vez en una excursión y acabé refugiándome en un bar de pueblo con un chocolate caliente. ¿Pudisteis encontrar algún sitio donde entrar en calor?
- User: Por la noche cenamos en un restaurante muy carino, la comida era buenísima pero el cuenta fue muy alta. (expect: carino, el cuenta)
  - Fix: carino -> bonito; era -> estaba; el cuenta -> la cuenta
  - Tutor: Al menos la comida estuvo a la altura, aunque una cuenta desorbitada puede aguar hasta el mejor recuerdo. A mí me consuela pensar que, de vez en cuando, una cena memorable también incluye el momento de mirar el recibo y parpadear dos veces. ¿Qué plato pedisteis?
- User: Mañana tengo que trabajar, pero antes quiero hacer un poco de workout en el parque. (expect: workout)
  - Fix: workout -> ejercicio
  - Tutor: ¡Buen plan! Entrenar al aire libre despeja la cabeza, aunque mañana quizá cueste un poco arrancar si hace fresco. Yo suelo salir a caminar antes de trabajar: no es precisamente una sesión de gimnasio, pero me deja con las pilas cargadas. ¿Qué tipo de ejercicio tienes pensado hacer?
- User: Si tendría más tiempo, aprendería a cocinar platos españoles, sobretodo la paella. (expect: tendría, sobretodo)
  - Fix: Si tendría -> Si tuviera; sobretodo -> sobre todo
  - Tutor: La paella merece tiempo y mimo: el punto del arroz no perdona, y cada cual tiene una opinión tajante sobre qué ingredientes son intocables. A mí me gusta la versión más sencilla, con buen caldo y un socarrat bien hecho; ¿qué tipo de paella te gustaría aprender a preparar?
- User: Mi hermana dice que la paella de Valencia es la mejor, pero yo no la he probado ancora. (expect: ancora)
  - Fix: ancora -> todavía
  - Tutor: Pues tendrás que ponerle remedio: la paella valenciana auténtica tiene fama de llevar ingredientes muy concretos, aunque sobre eso se discute más que de fútbol. Yo la probé en Valencia y me sorprendió lo distinta que era de las versiones que suelen servir fuera; ¿qué ingredientes lleva la que prepara tu hermana?
