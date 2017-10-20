--通配符测试
if object_id('dbo.tstudent','U') is not null drop table tstudent; 
create table tstudent(id int identity(1,1) not null primary key,
name varchar(100) );

insert into tstudent(name) values
('Abigail 艾比盖 希伯来 父亲很高兴；得意的父亲。   '),
('Ada， 埃达， 英国， 增光；快乐的；美丽。 '),
('Adela， 爱得拉 德国， 尊贵的；优雅的。 '),
('Adelaide， 爱得莱德， 德国， 高贵的；高贵阶级的。 '),
('Afra， 阿芙拉 希伯来 尘土 '),
('Agatha， 阿加莎 希腊， 善良而美好的 '),
('Agnes， 爱葛妮丝， 希腊，拉丁， 纯洁，高雅，贞节 '),
('Alberta 爱尔柏塔， 英国， 高贵显赫的。 '),
('Alexia， 爱莉克希亚， 希腊， 帮助 '),
('Alice， 艾丽斯 希腊， 尊贵的，真诚的'),
('Alma， 爱玛， 拉丁，英国， 真情的、和善的、舞女。 '),
('Althea， 奥尔瑟雅， 希腊， 好预，医治者。 '),
('Alva， 阿尔娃 拉丁， 白皙的。 '),
('Amelia， 阿蜜莉雅， 拉丁， 勤勉的，劳动的。'),
('Ameli， 阿蜜莉 英文 美丽的 善良的。'),
('Amy， 艾咪， 法国， 最心爱的人，可爱的。 '),
('Anastasia， 阿娜丝塔西夏， 希腊， 再度振作起来之人，复活。 '),
('Andrea， 安德烈亚， 希腊， 有气概，美丽而优雅 '),
('Ann， 安妮， 希伯来 优雅的，仁慈的上帝。 '),
('Anna， 安娜， 希伯来 优雅 '),
('Annabelle， 安纳贝尔， 希伯来，拉丁， 美丽的女子；可爱的； 和蔼可亲的。 '),
('Antonia 安东妮儿， 拉丁，希腊， 无辞以赞，受尊崇的人。 '),
('April， 艾谱莉 拉丁， 春天，大地初醒之时。 '),
('Arabela 爱勒贝拉， 拉丁，日耳曼， 美丽的祭坛，易于请求 '),
('Arlene， 艾琳娜 赛尔特 誓约、信物。 '),
('Astrid， 艾丝翠得， 丹麦， 神圣的力量；星星的。 '),
('Atalanta， 亚特兰特， 希腊， 跑得快的美丽少女。 '),
('Athena， 阿西娜 希腊， 希腊神话中，智慧、及战争的女神，雅典的保护神。 '),
('Audrey， 奥德丽 法国， 高贵显赫的人。 '),
('Aurora， 奥劳拉 拉丁， 黎明女神 '),
('Barbara 芭芭拉 希腊， 外地来的人，异乡人；异族人。 '),
('Beatrice， 碧翠丝 拉丁， 为人祈福或使人快乐的女孩 '),
('Belinda 贝琳达 德国、意大利， 像条蛇。有智慧又长寿的人。 '),
('Bella， 贝拉， 拉丁， 美丽的 '),
('Belle， 贝拉， 法国， 美丽的；上帝的誓约；聪明高贵。 '),
('Bernice 柏妮丝 希腊， 带着胜利讯息来的人。 '),
('Bertha， 柏莎， 条顿， 聪明、美丽或灿烂的。 '),
('Beryl， 百丽儿 希腊， 绿宝石，幸运。 '),
('Bess， 贝丝， 希伯来 上帝是誓约。 '),
('Betsy， 贝齐， 希伯来 上帝是誓约。 '),
('Betty， 贝蒂， 希伯来 上帝是誓约。 '),
('Beulah， 比尤莱 希伯来 已结婚的。 '),
('Beverly 贝芙 丽， 英国， 有海狸的小河。 '),
('Blanche 布兰琪 条顿， 纯洁无暇的；白种人的；白皙美丽的。 '),
('Bblythe 布莱兹 英国， 无忧无虑的；快乐的。 '),
('Breenda 布伦达 盖尔， 挑拨者；剑；黑发 '),
('Bridget 布里奇特， 盖尔或爱尔兰， 强壮，力量 '),
('Brook， 布鲁克 英国， 傍溪而居之人。 '),
('Camille 卡米拉 拉丁， 好品性的高贵女子。 '),
('Candance， 坎蒂丝 拉丁， 热情，坦诚，纯洁的。 '),
('Candice 坎蒂丝 拉丁， 热情，坦诚，纯洁的。 '),
('Cara， 卡拉， 意大利 朋友；亲爱的人。 '),
('Carol， 卡萝， 法国， 欢唱，悦耳欢快的歌 '),
('Caroline， 卡罗琳 条顿， 骁勇、刚健和强壮的。 '),
('Catherine， 凯瑟琳 希腊， 纯洁的人。 '),
('Cathy， 凯丝，凯瑟琳的呢称。 希腊， 纯洁的人。 '),
('Cecilia 塞西莉亚， 拉丁， 视力朦胧的人，失明的。 '),
('Celeste 西莱斯特， 拉丁， 最幸福的人，天国的。 '),
('Charlotte， 夏洛特 法国， 身体强健女性化的。 '),
('Cherry， 绮莉， 法国， 仁慈，像樱桃般红润的人。 '),
('Cheryl， 谢里尔 法国， 珍爱的人，男子汉 '),
('Chloe， 克洛怡 希腊， 青春的，美丽的。 '),
('Christine， 克里斯廷， 希腊， 基督的追随者，门徒。 '),
('Claire， 克莱儿 拉丁， 灿烂的；明亮的；聪明的。 '),
('Clara， 克莱拉 拉丁， 明亮的；聪明的。 '),
('Clementine， 克莱曼婷， 拉丁， 温柔且仁慈的人。 '),
('Constance， 康斯坦丝， 拉丁， 坚定忠实的人。 '),
('Cora， 科拉， 希腊， 处女；少女。 '),
('Coral， 卡洛儿 希腊，法国， 珊瑚或赠品，彩石。 '),
('Cornelia， 可妮莉雅， 希腊， 山茱萸树，号角。 '),
('Daisy， 黛西， 英国， 雏菊。 '),
('Dale， 黛儿， 英国， 居住在丘陵间之山谷中者。 '),
('Dana， 黛娜， 希伯来 来自丹麦的人；神的母亲；聪明且纯洁的。 '),
('Daphne， 黛芙妮 希腊神话， 月桂树；桂冠。 '),
('Darlene 达莲娜 英国， 温柔可爱；体贴地爱。 '),
('Dawn， 潼恩， 英国， 黎明，唤醒，振作。 '),
('Debby， 黛碧， 希伯来 蜜蜂；蜂王。 '),
('Deborah 德博拉 希伯来 蜜蜂；蜂王。 '),
('Deirdre 迪得莉 盖尔， 忧愁的。 '),
('Delia， 迪丽雅 希腊， 牧羊女 '),
('Denise， 丹尼丝 希腊， 代表花。 '),
('Diana， 黛安娜 拉丁， 光亮如白画；月亮女神 '),
('Dinah， 黛娜， 希伯来 被评判的人，雅各布的女儿。'),
('Dolores 多洛雷斯， 拉丁， 悲伤，痛苦或遗憾。 '),
('Dominic 多明尼卡， 拉丁， 属于上帝的。 '),
('Donna， 唐娜， 拉丁， 贵妇，淑女，夫人。 '),
('Dora， 多拉， 希腊， 神的赠礼。 '),
('Doreen， 多琳， 希腊， 神的赠礼。 '),
('Doris， 多莉丝 希腊， 来自大海的；海洋女神。 '),
('Dorothy 桃乐斯 希腊， 上帝的赠礼。 '),
('Eartha， 尔莎， 英国， 土地或泥土；比喻像大地般坚忍的人。 '),
('Eden， 伊甸， 希伯来 圣经中的乐园，欢乐之地。 '),
('Edith， 伊迪丝 古英国 格斗；战争。 '),
('Edwina， 艾德文娜， 英国， 有价值的朋友；财产的获得者。 '),
('Eileen， 艾琳， 盖尔， 光亮的，讨人喜欢的。 '),
('Elaine， 伊莲恩 法国， 光亮的；年幼的小鹿。 '),
('Eleanore， 艾琳诺 法国， 光亮的；多产的，肥沃的，有收获的。 '),
('Elizabeth， 伊丽莎白， 希伯来 上帝的誓约。 '),
('Ella， 埃拉， 条顿， 火炬 '),
('Ellen， 艾伦， 希腊、拉丁， 火把 '),
('Elma， 艾尔玛 希腊， 富爱心的人，亲切的。 '),
('Elsa， 爱尔莎 希腊， 诚实的。 '),
('Elsie， 艾西， 希伯来，希腊， 上帝的誓约，诚实的。 '),
('Elva， 艾娃， 斯堪的那维亚， 神奇且智慧的。 '),
('Elvira， 埃尔韦拉 拉丁， 小精灵，白种人的。 '),
('Emily， 埃米莉 条顿，拉丁， 勤勉奋发的；有一口响亮圆润的嗓音之人 ； '),
('Emma， 埃玛， 条顿， 祖先。 '),
('Erica， 艾丽卡 条顿， 有权力的；帝王的；统治者。 '),
('Erin， 艾琳， 盖尔， 镶在海中是的翡翠；和平，安宁之源。 '),
('Esther， 艾丝特 希伯来 星星 '),
('Eudora， 尤多拉 希腊， 可爱的赠礼，美好的、愉快的。 '),
('Eunice， 尤妮斯 希腊， 快乐的胜利。'),
('Evangeline， 伊文捷琳， 希腊， 福音的信差，福音；天使 '),
('Eve， 伊芙， 希伯来 生命；赋予生命者生灵之母 '),
('Evelyn， 伊夫林 塞尔特 生命；易相处的人；令人愉快的人。 '),
('Faithe， 费滋， 拉丁， 忠实可信的人。 '),
('Fanny， 梵妮， 法国， 自由之人。 '),
('Fay， 费怡， 法国， 忠贞或忠诚；小仙女。 '),
('Flora， 弗罗拉 拉丁， 花；花之神 '),
('Florence， 弗罗伦丝， 塞尔特 开花的或美丽的。 '),
('Frances 弗朗西斯， 法国， 自由之人，无拘束的人。 '),
('Freda， 弗莉达 德国， 和平；领导者。 '),
('Frederica， 菲蕾德翠卡， 条顿， 和平的领导者。 '),
('Gabrielle， 嘉比里拉， 希伯来 上帝就是力量。 '),
('Gail， 盖尔， 英国， 快乐的；唱歌；峡谷。 '),
('Gemma， 姬玛， 意大利 宝石 '),
('Genevieve， 珍妮芙 古韦尔斯， 金发碧眼的人；白种人。 '),
('Georgia 乔治亚 希腊， 农夫。 '),
('Geraldine， 杰拉尔丁 德国， 强而有力的长矛。 '),
('Gill， 姬儿， 拉丁， 少女。 '),
('Giselle 吉榭尔 条顿， 一把剑 '),
('Gladys， 格拉迪斯， 韦尔斯 公主。 '),
('Gloria， 葛罗瑞亚， 拉丁， 荣耀者，光荣者。 '),
('Grace， 葛瑞丝 英国，法国，拉丁， 优雅的。 '),
('Griselda， 葛莉谢尔达， 德国， 指对丈夫极顺从和忍耐的女人。 '),
('Gustave 葛佳丝塔芙， 德国，瑞典， 战争。 '),
('Gwendolyn， 关德琳 塞尔特 白色眉毛的。 '),
('Hannah， 汉纳， 希伯来 优雅的。 '),
('Harriet 哈莉特 法国， 家庭主妇 '),
('Hazel， 海柔尔 英国， 领袖，指挥官。 '),
('Heather 赫瑟尔 英国， 开花的石楠。 '),
('Hedda， 赫达， 德国， 斗争或战斗。 '),
('Hedy， 赫蒂， 希腊， 甜蜜，又令人欣赏的。 '),
('Helen， 海伦， 希腊，拉丁， 火把；光亮的。 '),
('Heloise 海洛伊丝， 法国， 健全的；在战场上很出名。 '),
('Hilda， 希尔达 条顿， 战斗；女战士 '),
('Hilary， 希拉瑞莉， 拉丁， 快乐的。 '),
('Honey， 汉妮， 英国， 亲爱的人。 '),
('Hulda， 胡尔达 条顿， 优雅，被大众深深喜爱的。 '),
('Ida， 埃达， 德国， 快乐的，勤奋的，富有的。 '),
('Ina， 艾娜， 拉丁， 母亲。 '),
('Ingrid， 英格丽 斯堪的那维亚， 女儿；可爱的人。 '),
('Irene， 艾琳， 法国，拉丁， 和平；和平女神。 '),
('Iris， 爱莉丝 拉丁， 彩虹女神；鸢尾花。 '),
('Irma， 艾尔玛 拉丁，条顿， 地位很高的；高贵的 '),
('Isabel， 伊莎蓓尔， 希伯来 上帝的誓约。 '),
('Ivy， 艾薇， 希腊， 希腊传说中的神圣食物。 '),
('Jacqueline， 杰奎琳 法国， 愿上帝保护。 '),
('Jamie， 婕咪， 拉丁， 取而代之者。 '),
('Jane， 珍， 希伯来，法国， 上帝是慈悲的；少女。 '),
('Janet， 珍妮特 希伯来，法国， 少女，上帝的恩赐 '),
('Janice， 珍尼丝 希伯来，法国， 少女；上帝是仁慈的。 '),
('Jean， 琴， 法国， 上帝是慈悲的。 '),
('Jill， 姬儿， 神话， 少女；恋人。 '),
('Jo， 乔， 苏格兰 恋人。 '),
('Joa， 琼， 法国，神话， 上帝仁慈的赠礼。 '),
('Joanna， 乔安娜 希伯来 上帝仁慈的赠礼。 '),
('Joanne， 希伯来 希伯来 上帝仁慈的赠礼。 '),
('Jocelyn 贾思琳 拉丁， 愉快的；快乐的 '),
('Jodie， 乔蒂， 希伯来 非常文静；赞美。 '),
('Josephine， 约瑟芬 希伯来 增强；多产的女子。 Joy， 乔伊， 拉丁， 欣喜；快乐 '),
('Joyce， 乔伊斯 拉丁， 快乐的；欢乐的。 '),
('Judith， 朱蒂斯 希伯来 赞美；文静之女子。 '),
('Judy， 朱蒂， 希伯来 赞美。 '),
('Julia， 朱莉娅 拉丁， 头发柔软的；年轻。 '),
('Julie， 朱莉， 希腊， 有张柔和平静脸庞的。 '),
('Juliet， 朱丽叶 拉丁， 头发柔软的；年轻的。 '),
('June， 朱恩， 拉丁， 六月。 '),
('Kama， 卡玛， 印度， 爱之神。 '),
('Karen， 凯伦， 希腊， 纯洁。 '),
('Katherine， 凯瑟琳 希腊， 纯洁的。 '),
('Kay， 凯伊， 英国， 欣喜的；阿瑟王之兄弟。 '),
('Kelly， 凯莉， 盖尔， 女战士。 '),
('Kimberley， 金百莉 英国， 出生皇家草地上的人。 '),
('Kitty， 吉蒂， 希腊， 纯洁的。 '),
('Kristin 克里斯廷， 希腊， 基督的追随者、门徒。 '),
('Laura， 罗拉， 拉丁， 月桂树；胜利。 '),
('Laurel， 罗瑞尔 拉丁， 月桂树；胜利。 '),
('Lauren， 罗伦， 拉丁， 月桂树。 '),
('Lee， 李， 英国， 草地的居民；庇护所。 '),
('Lena， 莉娜， 拉丁， 寄宿；寓所。 '),
('Leona， 利昂娜 拉丁， 狮。 '),
('Lesley， 雷思丽 盖尔， 来自老的保垒；冬青园。 '),
('Letitia 列蒂西雅， 拉丁，西班牙， 快乐的；欣喜的。 '),
('Lilith， 李莉斯 希伯来 属于晚上的。 '),
('Lillian 丽莲， 希腊， 一朵百合花，代表纯洁；上帝的誓约。 '),
('Lindsay 林赛， 条顿， 来自海边的菩提树。 '),
('Lisa， 莉萨， 希伯来 对神奉献。 '),
('Liz， 莉斯， 希伯来 上帝就是誓约。 '),
('Lorraine， 洛兰， 法国， 来自法国洛林小镇的人。 '),
('Louise， 璐易丝 条顿， 著名的战士。 '),
('Lydia， 莉迪亚 英国， 来自里底亚的人，财富。 '),
('Lynn， 琳， 英国， 傍湖而居的人。 '),
('Mabel， 玛佩尔 拉丁， 温柔的人，和蔼亲切的人。 '),
('Madeline， 玛德琳 希腊， 伟大而崇高的；塔堡。 '),
('Madge， 玛琪， 拉丁， 珍珠。 '),
('Maggie， 玛吉， 拉丁， 珍珠。 '),
('Mamie， 梅蜜， 希伯来 反抗的苦涩；海之女。 '),
('Mandy， 曼蒂， 拉丁， 值得爱的。 '),
('Marcia， 玛西亚 拉丁， 女战神。 '),
('Margaret， 玛格丽特， 拉丁， 珍珠。 '),
('Marguerite， 玛格丽特， 希腊， 珍珠。 '),
('Maria， 玛丽亚 希伯来 悲痛、苦味。 '),
('Marian， 玛丽安 希伯来，拉丁， 想要孩子的；优雅的。 '),
('Marina， 马丽娜 拉丁， 属于海洋的。 '),
('Marjorie， 玛乔丽 法国， 珍珠。 '),
('Martha， 马莎， 阿拉姆 家庭主妇。 '),
('Martina 玛蒂娜 拉丁， 战神。 '),
('Mary， 玛丽， 希伯来 反抗的苦涩；海之女。 '),
('Maud， 穆得， 日耳曼 强大的；力量。 '),
('Maureen 穆琳， 盖尔， 小玛丽。 '),
('Mavis， 梅薇思 塞尔特 如画眉鸟的歌声；快乐。 '),
('Maxine， 玛可欣 拉丁， 女王。 '),
('Mag， 麦格， 拉丁， 珍珠。 '),
('May， 梅， 拉丁， 少女，五月 '),
('Megan， 梅根， 希腊， 伟大，强壮能干的人。 '),
('Melissa 蒙莉萨 希腊， 蜂蜜。 '),
('Meroy， 玛希， 英国， 慈悲；同情；仁慈。 '),
('Meredith， 玛莉提丝， 威尔丝 大海的保卫者。 '),
('Merry， 梅莉， 英国， 充满乐趣和笑声。 '),
('Michelle， 米歇尔 希伯来 紫菀花。 '),
('Michaelia， 蜜雪莉雅， 希伯来 似上帝的人。 '),
('Mignon， 蜜妮安 法国， 细致而优雅。 '),
('Mildred 穆得莉 英国， 和善的顾问；温柔的，和善的。 '),
('Miranda 米兰达 拉丁， 令人钦佩或敬重的人。 '),
('Miriam， 蜜莉恩 希伯来 忧伤；苦难之洋。 '),
('Modesty 摩黛丝提， 拉丁， 谦虚的人。 '),
('Moira， 茉伊拉 希腊， 命运。 '),
('Molly， 茉莉， 希伯来 反抗的苦涩；海之女。 '),
('Mona， 梦娜， 希腊， 孤独；高贵；唯一的，独特的；荒地 '),
('Monica， 莫妮卡 拉丁， 顾问。 '),
('Muriel， 穆丽儿 希伯来 悲痛、苦味；光明。 '),
('Murray， 玛瑞， 盖尔， 海员 '),
('Myra， 玛拉， 拉丁， 令人折服的人，非常好的人。 '),
('Myrna， 蜜尔娜 塞尔特 彬彬有礼。 '),
('Nancy， 南希， 希伯来 优雅、温文；保母。 '),
('Naomi， 娜娥迷 希伯来 我的欣喜；文雅美貌。 '),
('Natalie 纳塔利 法国， 圣诞日出生的。 '),
('Natividad， 娜提雅维达， 西班牙 在圣诞节出生的。 '),
('Nelly， 内丽， 希丽、拉丁， 火把。 '),
('Nicola， 妮可拉 希腊， 胜利。 '),
('Nicole， 妮可， 希腊， 胜利者 '),
('Nina， 妮娜， 拉丁， 有势有的；孙女。 '),
('Nora， 诺拉， 拉丁， 第九个孩子。 '),
('Norma， 诺玛， 拉丁， 正经的人，可做范的人。 '),
('Novia， 诺维雅 拉丁， 新来的人。 '),
('Nydia， 妮蒂亚 拉丁， 来自隐居之处的人。 '),
('Octavia 奥克塔薇尔， 拉丁， 第八个小孩。 '),
('Odelette， 奥蒂列特， 法国， 声音如音乐般。 '),
('Odelia， 奥蒂莉亚， 法国， 身材娇小；富有。 '),
('Olga， 欧尔佳 俄国， 神圣的；和平。 '),
('Olive， 奥丽芙 拉丁， 和平者；橄榄。 '),
('Olivia， 奥丽薇亚， 拉丁， 和平者；橄榄树。 '),
('Ophelia 奥菲莉亚， 希腊， 帮助者；援助者；蛇。 '),
('Pag， 佩格， 拉丁， 珍珠。 '),
('Page， 蓓姬， 希腊， 孩子。 '),
('Pamela， 帕梅拉 英国，希腊， 令人心疼，又喜恶作剧的小孩。 '),
('Pandora 潘多拉 法国， 世界上第一个女人。 '),
('Patricia， 派翠西亚， 拉丁， 出身高贵的。 '),
('Paula， 赛拉， 拉丁， 比喻身材娇小玲珑者 '),
('Pearl， 佩儿， 拉丁， 像珍珠般。 '),
('Penelope， 佩内洛普， 希腊， 织布者；沉默的编织者。 '),
('Penny， 潘妮， 希腊， 沉默的编织者。 '),
('Philipppa， 菲莉帕 希腊， 爱马者 '),
('Phoebe， 菲碧， 希腊， 会发亮之物，显赫的人，月之女神。 '),
('Phoenix 菲妮克丝， 希腊， 年轻的女人。 '),
('Phyllis 菲丽丝 希腊， 嫩枝，小花瓣，绿色小树枝。 '),
('Polly， 珀莉， 希伯来 反抗的苦涩；海之女。 '),
('Poppy， 波比， 拉丁， 可爱的花朵； '),
('Prima， 普莉玛 拉丁， 长女。 '),
('Priscilla， 普莉斯拉， 拉丁， 古代的人。 '),
('Prudence， 普鲁登斯， 拉丁， 有智慧、有远见之人；谨慎。 '),
('Queena， 昆娜， 英国， 很高贵、贵族化的。 '),
('Quintina， 昆蒂娜 拉丁， 第五个孩子。 '),
('Rachel， 瑞琪儿 希伯来 母羊或小羊；和善的、彬彬有礼的。 '),
('Rae， 瑞伊， 希伯来 母羊。 '),
('Renata， 蕾娜塔 希伯来 再生的；更新，恢复。 '),
('Renee， 蕾妮， 法国， 再生的。 '),
('Rita， 莉达， 意大利 珍珠；勇敢的；诚实的。 '),
('Riva， 莉娃， 法国， 在河堤或河边的人。 '),
('Roberta 罗伯塔 条顿， 辉煌的名声；灿烂。 '),
('Rosalind， 罗莎琳德， 拉丁， 盛开的玫瑰。 '),
('Rose， 罗丝， 拉丁， 玫瑰花，盛开；马。 '),
('Rosemary， 鲁思玛丽， 拉丁， 大海中的小水珠；艾菊。 '),
('Roxanne 罗克珊， 波斯， 显赫的人，有才气的人。 '),
('Ruby， 露比， 法国， 红宝石。 '),
('Ruth， 鲁思　 希伯来 友谊；同情。 '),
('Sabina， 莎碧娜 拉丁， 出身高贵的人。 '),
('Sally， 莎莉， 希伯来 公主。 '),
('Sabrina 莎柏琳娜， 拉丁， 从边界来的人。 '),
('Salome， 莎洛姆 希伯来 和平的，宁静的。 '),
('Samantha， 莎曼撤 阿拉姆 专心聆听教诲的人。 '),
('Sandra， 珊多拉 希腊， 人类的保卫者。 '),
('Sandy， 仙蒂， 希腊， 人类的保卫者。 '),
('Sara， 莎拉， 希伯来 公主。 '),
('Sarah， 赛拉， 希伯来 公主。 '),
('Sebastiane， 莎芭丝提安， 希腊， 受尊重的或受尊崇的。 '),
('Selena， 萨琳娜 拉丁， 月亮，月光。 '),
('Sharon， 沙伦， 盖尔， 很美的公主；平原。 '),
('Sheila， 希拉， 爱尔兰 少女；年轻女人；盲目的。 '),
('Sherry， 雪莉， 英国， 来自草地的。 '),
('Shirley 雪莉， 英国， 来自草地的。 '),
('Sibyl， 希贝儿 希腊， 女预言家。 '),
('Sigrid， 西格莉德， 斯堪的那维亚， 最被喜爱的人；胜利的。 '),
('Simona， 席梦娜 希伯来 被听到。 '),
('Sophia， 苏菲亚 希腊， 智慧的人。 '),
('Spring， 丝柏凌 英国， 春天。 '),
('Stacey， 斯泰西 希腊， 会再度振作起来之人。 '),
('Setlla， 丝特勒 西班牙 星星。 '),
('Stephanie， 丝特芬妮， 希腊， 王冠；花环；荣誉的标志。 '),
('Susan， 苏珊， 希伯来 一朵小百合。 '),
('Susanna 苏珊娜 希伯来 百合花。 '),
('Susie， 苏西， 希伯来 百合花。 '),
('Suzanne 苏珊， 希伯来 一朵小百合。 '),
('Tabitha 泰贝莎 希腊， 小雌鹿。 '),
('Tammy， 泰蜜， 希腊， 太阳神。 '),
('Teresa， 特莉萨 葡萄牙 丰收。 '),
('Tess， 泰丝， 法国， 丰收。 '),
('Thera， 席拉， 希腊， 指野女孩。 '),
('Theresa 泰莉萨 希腊， 收获。 '),
('Tiffany 蒂法尼 法国， 薄纱；神圣。 '),
('Tobey， 托比， 希伯来 鸽子，美好的，有礼貌的 '),
('Tracy， 翠西， 法国， 市场小径。 '),
('Trista， 翠丝特 拉丁， 以微笑化解忧伤的女孩。 '),
('Truda， 杜达， 条顿， 受喜爱的女孩。 '),
('Ula， 优拉， 条顿， 拥有祖产，并会管理的人。 '),
('Una， 优娜， 盖尔，英国，拉丁， 怪人，一人，唯一无二的。 '),
('Ursula， 厄休拉 拉丁， 褐色的头发，无畏之人。 '),
('Valentina， 范伦汀娜， 拉丁， 健康者，强壮者。 '),
('Valerie 瓦勒莉 拉丁， 强壮的人；勇敢的人。 '),
('Vera， 维拉， 俄国，拉丁， 诚实，忠诚。 '),
('Verna， 维娜， 希腊， 春天的美女；赋于美丽的外表。 '),
('Veromca 维隆卡 希腊， 胜利者。 '),
('Veronica， 维拉妮卡， 希腊， 带来胜利讯息者。 '),
('Victoria， 维多利亚， 拉丁， 胜利。 '),
('Vicky， 维基， 拉丁， 胜利。 '),
('Violet， 维尔莉特， 苏格兰、意大利 紫罗兰；谦虚。 '),
('Virginia， 维吉妮亚， 拉丁， 春天；欣欣向荣状。 '),
('Vita， 维达， 西班牙 指其生命之力，流过所有生灵的那种女人。 '),
('Vivien， 维文， 法国， 活跃的。 '),
('Wallis， 华莉丝 苏格兰 异乡人。 '),
('Wanda， 旺妲， 条顿， 树干；流浪者。 '),
('Wendy， 温迪， 条顿， 有冒险精神的女孩；白眉毛的；另一种。 '),
('Winifred， 威尼弗雷德， 韦尔斯 白色的波浪；和善的朋友。 '),
('Winni， 温妮， 韦尔斯 白色的波浪；和善的朋友。 '),
('Xanthe， 桑席， 希腊， 金黄色头发的。 '),
('Xaviera 赛薇亚拉， 西班牙 拥有新居，并善于保护新居的人。 '),
('Xenia， 芝妮雅 希腊， 好客。 '),
('Yedda， 耶达， 英国， 天生有歌唱的才华。 '),
('Yetta， 依耶塔 英国， 慷慨之捐赠者。 '),
('Yvette， 依耶芙特， 法国， 射手或弓箭手。 '),
('Yvonne， 伊芳， 法国， 射手。 '),
('Zara， 莎拉， 希伯来 黎明。 '),
('Zenobia 丽诺比丽， 拉丁、希腊， 父亲的光荣；狩猎女神。 '),
('Zoe， 若伊， 希腊， 生命。 '),
('Zona， 若娜， 拉丁， 黎明。 '),
('Zora， 若拉， 斯拉夫 黎明。'),
('Tomz_'),('Jerry%'),('J[D]'),('1'),('2'),('3'),('4'),('5'),('6'),('7'),('8'),('9'),('10')



select * from tstudent where 
--name like '%A%' --包含A
--name like 'A%' --A开头
--name like '%A%A%' --包含至少两个A
--name like '_A%' --第二个字母为A
--name like '[ADZ]%' --A/D/Z开头
--name like '[Y-Z]%'--Y-Z开头
--name like '[1-9]%'--1-9开头
--name like '[^A-D]%' --不是A-D开头的
--name like '[^A-D,0-9]%' --不是A-D开头的也不是数字开头的
name like '%[_]%' or name like '%![%' escape '!'--含'_'或者'['的

 drop table tstudent; 