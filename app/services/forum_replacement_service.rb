class ForumReplacementService < Service
  # Cool replacements we could eventually do not for pranking
  # [roll N] = random number between 1 and N
  # [roll N, M] = random number between N and M
  # [@reader] = username of the reader

  # NOTE: could do this shader style on word replacements if we want a ui :) [ReplacementList(color, replacements, &active?)]

  # blackout replacements
  FORBIDDEN_WORD_REPLACEMENTS = {
    
  }

  SPAM_WORD_REPLACEMENTS = {
    'cash app'          => 'pls ban me andrew',
    'cashapp'           => 'hey mr andrew come over here'
  }

  # perspective changes, always surrounded by {} (e.g. {@reader} )
  PERSPECTIVE_REPLACEMENTS = {
    '@reader'           => Proc.new { |trigger, user| (user.nil? ? 'anonymous reader' : user.try(:display_name)) || 'anonymous reader' }
  }

  # turn on and off at will
  CASUAL_CHAOS_WORD_REPLACEMENTS = {
    'andrew'            => 'andrew (Our Supreme Lord and Overseer)',
    'amy'               => 'amy (the most wonderful woman in the world)',
  }

  REFERENCE_REPLACEMENTS = {
    # [[Character-4]]
  }

  # gremlin replacements
  GREMLINS_WORD_REPLACEMENTS = {
    '<3'                => "<span class='red-text'>&heart;</span>",
    '$5'                => '[̲̅$̲̅(̲̅5̲̅)̲̅$̲̅]',
    '0/10'              => '10/10',
    '1/10'              => '11/10',
    '2/10'              => '12/10',
    '3/10'              => '13/10',
    '6 hours'           => '1/4 of a day',
    '8 hours'           => '1/3 of a day',
    '10 hours'          => 'approximately 41.666666666667% of a day',
    '95 cents'          => 'Nickleback',
    'Coke'              => 'Pepsi',
    'Keanu Reeves'      => 'The One',
    'actor'             => 'pretenderbloke',
    'actors'            => 'pretenderblokes',
    'air'               => '<span class="grey-text">air</span>',
    'alchohol'          => 'giggle juice',
    'alien'             => 'extraterrestrial bopper',
    'aliens'            => 'extraterrestrial boppers',
    'alpha'             => 'beta',
    'an hour'           => 'exactly 3600 seconds',
    'announcement'      => 'shouty spouty',
    'announcements'     => 'shouty spouties',
    "April Fool's Day"  => 'the best holiday of the year',
    "April Fools Day"   => 'the best holiday of the year',
    'April 1'           => 'a better version of Christmas',
    'artist'            => 'visual illusionist',
    'artists'           => 'visual ilussionists',
    'asap'              => 'as ASAP as possible',
    'askew'             => 'cattywampus',
    'attorney'          => 'lawyerboi-at-law',
    'attornies'         => 'lawyerbois-at-law',
    'automatically'     => 'automagically',
    'autumn'            => 'rainseason (bestseason)',
    'aviators'          => 'cool kid shades',
    'avocado'           => 'greenseed toastmash',
    'aware'             => 'cognizant',
    'awesome'           => "bee's knees",
    'B&B'               => 'Bungeons & Bragons',
    'ball'              => 'blimpy bounce bounce',
    'balls'             => 'blimpy bounce bounces',
    'balloon'           => 'elastic breath trap',
    'balloons'          => 'elastic breath traps',
    'beanie'            => 'floppy headcover',
    'beanies'           => 'floppy headcovers',
    'bear'              => '(ᵔᴥᵔ)',
    'bears'             => '(ᵔᴥᵔ)(ᵔᴥᵔ)',
    'bed'               => 'nighttime dreamvessel',
    'beds'              => 'nighttime dreamvessels',
    'beta'              => 'alpha',
    'bird'              => 'government spy drone',
    'birds'             => 'government spy drones',
    'blood'             => 'human syrup',
    'bone'              => 'calcium bodystick',
    'bones'             => 'calcium bodysticks',
    'boot'              => 'humanhoof',
    'boots'             => 'humanhoofs',
    'bra'               => 'foam dome',
    'brain'             => 'skull control',
    'brains'            => 'skull controls',
    'bread'             => 'bumberhooten flourknuckles',
    'breathe'           => 'consume oxygen to produce carbon dioxide',
    'breathing'         => 'consuming oxygen to produce carbon dioxide',
    'broccoli'          => 'tiny tree',
    'bulbasaur'         => 'the best starter Pokemon',
    'butt'              => 'pooty',
    'butterflies'       => 'beautyflies',
    'butterfly'         => 'beautyfly',
    'candy'             => 'chocolate globbernaughts',
    'cane'              => 'boppinstick',
    'canes'             => 'boppinsticks',
    'caps lock'         => 'CRUISE CONTROL FOR COOL',
    'car'               => 'motorized rollingham',
    'carrot'            => 'snownose',
    'cars'              => 'motorized rollinghams',
    'cat'               => 'feline whiskerdoodle',
    'cats'              => 'feline whiskerdoodles',
    'cereal'            => 'pip pip gollywock',
    'chaos'             => 'extremely peaceful times you need not worry about',
    'chatting'          => 'chitterchattering',
    'changed'           => 'infested',
    'cheese omelette'   => 'omelette du fromage',
    'cheeseburger'      => 'beef wellington ensemble with cheese',
    'cheeseburgers'     => 'beef wellington ensembles with cheese',
    'child'             => 'ankle-biter',
    'clock'             => 'Small Ben',
    'clocks'            => 'Small Bens',
    'clown'             => 'loony chuckle fairy',
    'clowns'            => 'loony chuckle fairies',
    'coffee'            => 'bean soup',
    'computer'          => 'electrical miraclebox',
    'computers'         => 'electrical miracleboxes',
    'confuse'           => 'bumfuzzle',
    'confused'          => 'bumfuzzled',
    'cookie'            => 'choco chip bicky wicky',
    'cookies'           => 'choco chip bicky wickies',
    'counterclockwise'  => 'widdershin',
    'courtroom'         => 'legal objectionbox',
    'cranberry'         => 'wild redbean',
    'crazy'             => 'bonkers',
    'cumberbatch'       => 'Cramplescrunch',
    'curse'             => 'blurse',
    'cursed'            => 'blursed',
    'defence'           => 'uh-oh no-no',
    'defense'           => 'uh-oh no-no',
    'detective'         => 'hankshaw constable',
    'dog'               => 'woofy wolfscendent',
    'dogs'              => 'woofy wolfscendents',
    'door'              => 'wobbly flip-shutter',
    'doorbell'          => 'chimey pushknob',
    'doorbells'         => 'chimey pushknobs',
    'doorknob'          => 'twisting plankhandle',
    'doorknobs'         => 'twisting plankhandles',
    'doors'             => 'wobbly flip-shutters',
    'dragon'            => "big boppin' fire droppin' flyin' thing",
    'dragons'           => "big boppin' fire droppin' flyin' things",
    'earth'             => '<span class="brown-text">earth</span>',
    'electric'          => '<span class="yellow-text">electric</span>',
    'end my suffering'  => "I'm having an absolutely fine time",
    'escalator'         => 'upsy stairsy',
    'exhausted'         => 'wabbit knackered',
    'eye'               => 'peeper',
    'eyes'              => 'peepers',
    'eyo'               => '☜(⌒▽⌒)☞',
    'fake news'         => 'malarkey',
    'family'            => 'mandatory surname-sharers unit',
    'feet'              => 'groundhands',
    'fight'             => 'rumble donnybrook',
    'fire'              => '<span class="red-text">fire</span>',
    'firefighter'       => 'waterbender',
    'firework'          => 'merry fizzlebomb',
    'fireworks'         => 'merry fizzlebombs',
    'fish'              => 'aquatic blooper',
    'fishes'            => 'aquatic bloopers',
    'fortnite'          => 'hippity buildershooter',
    'forums'            => 'words warehouse',
    'foo'               => '<marquee direction="left">foooooooooooooooooooooooooooo</marquee>',
    'foot'              => 'groundhand',
    'fox'               => 'sneakyweak doggoboi',
    'foxes'             => 'sneakyweak doggobois',
    'frog'              => 'diddly croaker',
    'funny'             => 'laffy taffy',
    'geese'             => 'chonky honkies',
    'giraffe'           => 'wobbly longneck',
    'glitter'           => 'permasprinkles',
    'goose'             => 'chonky honky',
    'grass'             => 'groundfuzzy',
    'gravy'             => 'meat water',
    'greenhouse'        => 'clearhouse',
    'gun'               => 'rooty tooty point-n-shooty',
    'guns'              => 'rooty tooty point-n-shooties',
    'hamburger'         => 'beef wellington ensemble with lettuce',
    'hamburgers'        => 'beef wellington ensembles with lettuce',
    'hat'               => 'fuzzy head chimney',
    'hate'              => 'absolutely love',
    'h a t e'           => 'L O V E',
    'heart'             => '<em>corazón</em>',
    'hearts'            => '<em>corazones</em>',
    'hell'              => 'heck',
    'hello'             => 'howdy, partner',
    'hey all'           => 'greetings, earthlings',
    'hip'               => 'hep',
    'history'           => 'lastpast yesteryear',
    'homework'          => 'timey wimey studystruggles',
    'hot chocolate'     => 'boiled chocowater',
    'ice cold'          => 'cooler than being cool',
    'icky'              => 'oofy doofy',
    'insect'            => 'motorized freckle',
    'insects'           => 'motorized freckles',
    'jelly'             => 'fruit spleggings',
    'jugo de humano'    => 'blood',
    'keyboard'          => 'hoighty toighty tippy typer',
    'keyboards'         => 'hoighty toighty tippy typers',
    'kidnap'            => 'surprise adoption',
    'kitchen'           => 'fridge-and-oven combination room',
    'knife'             => 'stabby stick',
    'knives'            => 'stabby sticks',
    'la croix'          => 'water that has been in the vicinity of a fruit at one point in the past few years',
    'ladies and gentlemen' => 'guys, gals, and non-binary pals',
    'laptop'            => 'electrotablet with keys',
    'lechuga'           => 'lettuce',
    'lettuce'           => 'lechuga',
    'library'           => 'libary',
    'lightbulb'         => 'ceiling-bright',
    'lightbulbs'        => 'ceiling-brights',
    'lizard people'     => 'definitely normal human beings',
    'lock'              => 'lumberlatch',
    'locks'             => 'lumberlatches',
    'marker'            => 'crockety snapwicket',
    'markers'           => 'crockety snapwickets',
    'Mario'             => "Luigi's larger brother",
    'milk'              => 'cow juice',
    'mischief'          => 'happy fun times',
    'mistake'           => 'waggly gaff',
    'mistakes'          => 'waggly gaffs',
    'mitochondria'      => 'the powerhouse of the cell',
    'mittens'           => 'hand socks',
    'money'             => 'molded cheddar',
    'moon'              => 'night cheese',
    'mosquito'          => 'buzzy itchybee',
    'mosquitoes'        => 'buzzy itchybees',
    'movie'             => 'magical moving picture',
    'movies'            => 'magical moving pictures',
    'murder'            => 'mucduc',
    'narwhal'           => 'sea unicorn',
    'netflix and chill' => 'hulu and vibe',
    'nice'              => 'noice',
    'night'             => 'shadowtime',
    'nugget'            => "lil' nuggy",
    'nuggets'           => "lil' nuggies",
    'oh no'             => '<img src="http://2.bp.blogspot.com/_izy_T_tOZXY/SZwImBbXL8I/AAAAAAAABy4/FEEkvPJAD4g/s320/Kool-Aid.jpg" />',
    'offensive'         => 'bogue',
    'oof'               => '<marquee>oooooooooooooooooooooooooooooooooooooof</marquee>',
    'owo'               => '(◕‿◕✿)',
    'pancake'           => 'roundy-yum',
    'pancakes'          => 'roundy-yums',
    'parties'           => "poppin' brouhahas",
    'party'             => "poppin' brouhaha",
    'peanut butter'     => 'nutty-gum',
    'phone'             => 'cellular telephone',
    'phones'            => 'cellular telephones',
    'pen'               => 'whimsy flimsy mark and scribbler',
    'pens'              => 'whimsy flimsy mark and scribblers',
    'pepsi'             => 'Coke',
    'petunia'           => 'power flower',
    'petunias'          => 'power flowers',
    'pie'               => 'solid soup',
    'pluto'             => "lil' wannaplanet",
    'podcast'           => 'audiobobbles recording',
    'politician'        => 'public snollygoster',
    'politicians'       => 'public snollygosters',
    'poop'              => 'niffy loo pudding',
    'popsicle'          => 'cold on the cob',
    'prankster'         => 'funny-gunny laugh-a-tonny',
    'prison'            => 'hoosegow locker',
    'raccoon'           => 'trash burgler',
    'radio'             => 'magic musicbox',
    'rain'              => 'cloudy juice',
    'recursion'         => 'recursion',
    'replaced'          => 'improved',
    'reverse'           => 'esrever',
    'road'              => 'cobble-stone-clippity-clop',
    'roads'             => 'cobble-stone-clippity-clops',
    'room'              => 'human containment unit',
    'same'              => 'same',
    'sandwich'          => 'breaddystack',
    'sandwiches'        => 'breaddystacks',
    'school'            => 'the setting for my coming-of-age story',
    'Scoliosis'         => 'wiggly spine',
    'scream'            => 'loudy shouty',
    'sex'               => 'yiffy wiffy',
    'Severus Snape'     => 'Sexybeast Snacc',
    'sheep'             => 'fluffy bumpkinboo',
    'shenanigans'       => 'silly fun',
    'shoe'              => 'leather winklepicker',
    'shoes'             => 'leather winklepickers',
    'sick'              => 'collywobble icky',
    'skiing'            => 'slippery snownoodle moving',
    'skydiving'         => 'falling out of the sky',
    'sleep'             => 'night voyage',
    'smartwatch'        => 'cuff-link time Johnny',
    'smol'              => '<span style="font-size: 5px">smol</span>',
    'snake'             => 'slippery dippery long mover',
    'snakes'            => 'slippery dippery long movers',
    'snowman'           => 'temporary ice friend',
    'sock'              => 'soft foot hugger',
    'socks'             => 'soft foot huggers',
    'speakeasy'         => 'juicy joint',
    'spider'            => 'crawler octobrawler',
    'spongebob'         => 'absorbant squareguy',
    'spring'            => 'flowerseason',
    'stairs'            => 'broken escalator',
    'Stardew Valley'    => 'Farming Simulator 2016',
    'sticky'            => 'icky wicky',
    'stolen'            => 'nick wicketed',
    'stupid'            => 'stoopid',
    'success'           => 'Yahtzee!',
    'summer'            => 'sunseason',
    'sup'               => 'soup',
    'sweater'           => 'sheepity sleepity',
    'sweaters'          => 'sheepity sleepities',
    'sword'             => 'silver stabby-wabby',
    'swords'            => 'silver stabby-wabbies',
    'tall'              => 'giraffy',
    'tarantula'         => 'fuzzycrawler',
    'taxation'          => 'theft',
    'tea'               => 'leaf water',
    'teeth'             => 'mouthstones',
    'testosterone'      => 'man juice',
    'tiger'             => 'thundercat',
    'tigers'            => 'thundercats',
    'tissue'            => 'sneezepaper',
    'tissues'           => 'sneezepapers',
    'toe'               => 'foot finger',
    'toes'              => 'foot fingers',
    'toilet'            => 'porcelain poopshooter',
    'tomorrow'          => 'the day before two days from now',
    'tongue'            => 'flicky licker',
    'tonight'           => 'the night after last night',
    'tooth'             => 'mouthstone',
    'toy'               => 'bippity boppity',
    'tree'              => 'giant broccoli',
    'trees'             => 'giant broccolis',
    'trick'             => 'bamboozle',
    'tricked'           => 'bamboozled',
    'two days ago'      => 'a thousand years after 365002 days ago',
    'two weeks'         => 'a fortnight',
    'umbrella'          => 'bumbershoot',
    'unicorn'           => 'hornse',
    'uwu'               => '(｡◕‿‿◕｡)',
    'wand'              => 'rowdy spouty point-n-shouty',
    'wands'             => 'rowdy spouty point-n-shouties',
    'wasp'              => 'flying stingywingy',
    'wasps'             => 'flying stingywingies',
    'watch out'         => 'gardyloo',
    'water'             => '<span class="blue-text">water</span>',
    'wednesday'         => 'wendsday',
    'weed'              => "devil's lettuce",
    'weird'             => 'wonky-donky',
    'what is happening' => 'everything is fine',
    'whale'             => 'blubberbutt watermutt',
    'whales'            => 'blubberbutt watermutts',
    'wheeze'            => 'sneeze',
    'wheezing'          => 'sneezing',
    'winter'            => '<span class="blue-text">snowseason</span>',
    'wire'              => 'electro-rope',
    'wires'             => 'electro-ropes',
    'world hunger'      => 'the hardest problem known to man',
    'worm'              => 'wiggly biggly',
    'write'             => 'scribble scrabble',
    'writing'           => 'scribble scrabbling',
    'writer'            => 'scribble scrabbler',
    'writers'           => 'scribble scrabblers',
    'word'              => 'wod',
    'words'             => 'wods',
    'wordsmith'         => 'wodsmith',
    'yuge'              => '<span style="font-size: 40px">yuge</span>',
    'zalgo'             => 'H̶̛̼̼̪̝̞͓̞͕͇̯͚͎͚̘̳͕̱̤̠̗͔͇̙̣̰͓̖̰̯̀̓̐̑̇͊͂̀͋̒̐̓͒̒͊͊̕͜͝ͅE̴̡̧̨̨̲̥̯͎̭̻̩̞̘̞̪̞̗̭͖̻͙͕͎̮͕̺͕̲̘̻̣͚̳̥͍̙͈͚͍͉̗͙̱͖͚̾̂̇͛̉͋͊̾͛̆̀́͑͛̅̋͊̕͘͜͜͜͝ͅͅͅͅ ̸̡̡̨̡̨̛̞͎̹̩̬̗̗̞̬̰̮̙̪̖͈̣̹͔̺̫̰̓̔̉̋̈̈́͐́̿̈̀͊̿̈̉̅̃̊̽͗̈̿̈́̓̈́̎͌̄̀̆̌̎͗̋͒̋̿̋̊̈́͆̋̾̈̏̈́̋̿̕̕̚͝͝͠͠ͅͅͅC̵̛̘̳͙̪̭͖̲̞̯̰̜͇̈̾̈́͋̌̉̽̽͑̎͌̾̈́͌̑͊̊̔̀͆̌̀̇̓͊̀̂̇̿̃͑́̈́̆͂̈́̾̓́̂̂̓̂̍̍͛͆͌͌̽̎̍̀̒̆̀͗͋͘͘͘͝͠͝͝͠͝͝Ǫ̸͕̻̞̝̜͚̗̮̼͎̤͔̤̱͔̫͂̄̉̋̈͊͐͂̇̀̌̎́͑̐̀̈́͋̓̾̅͒̒̄͑̒̆̑̾͜͝͝͝͝M̷̧̧̡̨̛̛̩̭̞͍̼̝̗͕̖͇̣̣̩͆̿̑͒́̉̅̓̌̆̈́͐͒̾̐̂̿̓̚͘̚͜E̵̡̨̢̧̢̢̡̢̨̛̠̱̻̺̦͚̹͓̬͔̪̟̼̥̯̠̘͚̫̯͍̺͔̫̟͇̱̦̟̪͚͉̣̳͓͍̬̙̲͔̘͙͔̤̰̜͍̠̩͉͐̂̊̏̐̿̊̋͑̿̇̊̈́͗̎̋́́̉̓̂̐͑̇̐̐͋́̒̈́͛͑͒̂͒̂̔̀̄̈́̓͂͆̈́͒̌͆̓͗̋͐̔̑͐̕͘ͅͅͅŞ̴̧̧̡̢̧̡̢͕̝͚̝̖͚̣̞̫̻̯͔̳̗̝̰̗̰̰̥̭͕̜̜̫͍̪̳̘̣̺̠͉̗̟͕̹͇̬̘̘̪͆͗̎̕',
  }

  OVERLOAD_WORDS_REPLACEMENTS = {
    'bad'                   => 'bodge',
    'knee'                  => 'leg hinge',
    'knees'                 => 'leg hinges',
    'depression'            => 'megasadness',
    'ice cream'             => 'eyes cream',
    'life'                  => 'like a box of chocolates',
    'strawberry'            => 'plastic tubefruit',
    'gremlin'               => 'extremely smart alien being that is here to help',
    'gremlins'              => 'extremely smart alien beings that are here to help',
    'soul'                  => 'inner ghost',
    'dance'                 => 'woopwoop',
    'curling iron'          => 'medieval torture device',
    'insurance'             => 'the biggest scam known to man',
    'lemonade'              => 'sour drank',
    'salamander'            => 'baby dragon',
    'scrolling'             => 'vertically surfing through a screen',
    'subtext'               => 'subtweeting but IRL',
    'how'                   => 'how now brown cow',
    'midnight'              => 'dayover',
    'kill'                  => 'deathsnuggle',
    'babe'                  => 'bae',
    'video'                 => 'series of images played in rapid succession to give the illusion of movement on a static screen',
    'online'                => 'on the interwebs',
    'internet'              => 'series of electrotubes',
    'highlighted'           => 'becoming better',
    'backfired'             => 'went incredibly well',
    'football'              => 'soccer',
    'baseball'              => 'throwing soccer',
    'basketball'            => 'dribbling soccer',
    'volleyball'            => 'beach air soccer',
    'rule'                  => 'law you must obey',
    'rules'                 => 'laws you must obey',
    'why is this happening' => 'I think this is great'
  }

  def self.replace_for(text, user)
    gremlins_phase = 0
    replaced_text = text.dup

    # Page tag replacements
    replaced_text = ContentFormatterService.substitute_content_links(
      replaced_text,
      user
    )

    SPAM_WORD_REPLACEMENTS.each do |trigger, replacement|
      replaced_text.gsub!(/\b#{trigger.downcase}\b/i, wrapped(replacement, trigger, 'red'))
    end

    PERSPECTIVE_REPLACEMENTS.each do |trigger, replacement|
      replaced_text.gsub!(/{#{trigger.downcase}}/i, wrapped(replacement.call(trigger, user), trigger, 'blue'))
    end

    if true # not implemented: [[Character-123]] or https://www.notebook.ai/plan/characters/553 etc
      replaced_text.gsub!(/>https?:\/\/(?:www\.)?(?:(?:\w)+\.)?notebook\.ai\/plan\/([\w]+)\/([\d]+)</).each do |match|
        klass = $1.singularize

        linkable_whitelist = Rails.application.config.content_type_names[:all]
        if linkable_whitelist.include? klass.titleize
          #"><span class='chip js-load-page-name' data-klass='#{klass.titleize}' data-id='#{$2.to_i}'><span class='name-container'></span></span><"
          chip = ContentFormatterService.name_autoloaded_chip_template(klass.titleize.constantize, $2.to_i)

          ">#{chip}<"
        else
          match
        end
      end
    end

    if gremlins_phase >= 1
      CASUAL_CHAOS_WORD_REPLACEMENTS.each do |trigger, replacement|
        replaced_text.gsub!(/\b#{trigger.downcase}\b/i, wrapped(replacement, trigger, 'green'))
      end
    end

    if gremlins_phase >= 2
      GREMLINS_WORD_REPLACEMENTS.each do |trigger, replacement|
        replaced_text.gsub!(/\b#{trigger.downcase}\b/i, wrapped(replacement, trigger, 'green'))
      end
    end

    if gremlins_phase >= 3
      OVERLOAD_WORDS_REPLACEMENTS.each do |trigger, replacement|
        replaced_text.gsub!(/\b#{trigger.downcase}\b/i, wrapped(replacement, trigger, 'green'))
      end
    end

    replaced_text.html_safe
  end

  def self.wrapped(text, tooltip, color='blue')
    "<span class='#{color} lighten-5 tooltipped black-text' style='padding: 4px' data-tooltip='#{tooltip}'>#{text}</span>"
  end
end