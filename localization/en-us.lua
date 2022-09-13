local localization = {
    ["pc_stockmarket"] = "Stock Market", -- Stock market internet button

    ["login_name"] = "Name", -- Login "Name"
    ["login_password"] = "Password", -- Login "Password"
    ["login_login"] = "Login", -- Login button

    ["button_home"] = "Home", -- Home menu button
    ["button_stocks"] = "Stocks", -- Stocks menu button
    ["button_portfolio"] = "Portfolio", -- Portfolio menu button
    ["button_logout"] = "Logout", -- Logout menu button

    ["graph_time"] = "Time", -- Graph X Axis label
    ["graph_value"] = "Market Value", -- Graph Y Axis label

    ["info_value"] = "Value", -- Stock page "Value" text
    ["info_buy"] = "Buy", -- Stock page buy button
    ["info_sell"] = "Sell", -- Stock page sell button
    ["info_owned"] = "In Account", -- Stock "In Account" (Currently owned stocks) text
    ["info_transaction"] = "Cost of transaction", -- Transaction cost text
    ["info_post_portfolio"] = "Money after transaction", -- Total wealth / money after transaction text
    ["info_margin"] = "Profit", -- Profit text

    ["portfolio_accountValue"] = "Account Value", -- Portfolio graph Y Axis label
    ["portfolio_ownedStocks"] = "Owned Stocks", -- Portfolio owned stocks list description
    ["portfolio_totalMoney"] = "Total wealth", -- Portfolio total player money info
    ["portfolio_moneyInStocks"] = "In Stocks", -- Portfolio amount of money invested in stocks info

    ["news_noNews"] = "No news right now", -- News page no news placeholder
    ["news_toggleNotification"] = "Phone Notifications", -- News page toggle phone news botifications button

    -- https://cyberpunk.fandom.com/wiki/Corporations
    ["stockInfo_All Foods"] = "All Foods, Inc. is corporation based in Mexico which focuses on providing its customers with readily available quality food (usually meat based products). The majority of Allfoods products and their sales go to the United States.",
    ["stockInfo_Arasaka"] = "The Arasaka Corporation is a world-wide megacorporation dealing in corporate security, banking, and manufacturing. It is one of the most influential megacorporations in the world. Arasaka-branded weapons and military vehicles are among the most sought after by police and security firms.",
    ["stockInfo_Asukaga"] = "Asukaga & Finch (A&F) is an exclusive investment and financial counseling firm, based in New York, NUSA. The company was known for handling and investing very large sums of money on behalf of their global clients.",
    ["stockInfo_Biotechnica"] = "Biotechnica is a small corporation that created the genus of wheat that is refined into the synthetic fuel CHOOH2. They licenses the rights to use its genetically modified plants to petrochemical companies like Petrochem. Biotechnica also has a multitude of Bioware products on the market.",
    ["stockInfo_Budget Arms"] = "Budget Arms specializes in manufacturing dirt cheap and highly affordable weapons that can even be bought from the vending machines. Because of the low cost value proposition, reliability and performance of the weapons are not the main focus.",
    ["stockInfo_Cytech"] = "Cytech is a technology and biotechnology company specializing in inplants and cybernetic prostheses. Cytech is known for its high-quality products, all patented solutions developed in-house in the corporation's labs.",
    ["stockInfo_Darra Poly"] = "Darra Polytechnic is an India-based manufacturer of cheap and stylish weapons. Their weapons are often named after violent interstellar events that produce enough energy to be seen from Earth.",
    ["stockInfo_Delamain"] = "Delamain offers taxi transportation through its armored taxi cabs, driven by artificial intelligence, boasting transport to and from anywhere in Night City for reasonable fares. Delamain Cabs are made in partnership with Villefort and Militech.",
    ["stockInfo_DMS"] = "Diverse Media Systems, or DMS for short, is the second largest media corp behind only Network News 54, has been known to commonly be involved with them in skirmishes on the battlefield and in the boardroom. DMS was involved in a joint venture to create and distribute the first Braindances.",
    ["stockInfo_DTR"] = "Decker, Tanaka & Rogers (Short DTR) is a corporation involved in the freight shipping business, famous for its modern shipping fleet. During 2076, the company handled 53% of all of America's transport. Now DTR is one of the largest shipping corporations in the world.",
    ["stockInfo_Dyanlar"] = "Dynalar Technologies is a cyberware manufacturing corporation. They makes cyberware implants and specialize in chrome plated cybernetic arms for women. Many famous BD stars wear chrome plated arms built by Dynalar.",
    ["stockInfo_EZHomes"] = "EZHomes offers housing in all districts of night city. It provides an easy and paperless way of moving in and out, and is known for its often shady customers. They even offer high end apartments in some of Night Cities richest districts",
    ["stockInfo_Kang Tao"] = "Kang Tao is a Chinese weapons manufacturer, which was originally located in Taiwan. Kang Tao is an industry giant among the Taiwanese companies. However unlike the rest, it kept its independence by not selling out to the Japanese business.",
    ["stockInfo_Kaukaz"] = "Kaukaz is a soviet vehicle manufacturer from the USSR. The company mostly makes industrial trucks, such as the Kaukaz Bratsk U4020. Their vehicles are often bought by corps for heavy duty work.",
    ["stockInfo_Kiroshi"] = "Kiroshi Optics is a Japanese corporation that originated in the mountains of Nagano Prefecture. It's a relatively small Japanese corporate group that specializes in cyberware. It is widely regarded as the leading expert in producing optical cyberware.",
    ["stockInfo_Lazarus"] = "The Lazarus Military Operations Group or Lazarus Group, is a megacorporation entirely focused on private military contracting with operations across the globe ranging from single operatives to entire armored divisions. The Group's staunchest corporate ally is Militech.",
    ["stockInfo_Militech"] = "Militech is a megacorporation specializing in weapons manufacturing and private military contracting. They provide equipment for hundreds of nations as well as both private and governmental organizations, especially the NUSA military and police forces.",
    ["stockInfo_MoorE"] = "MoorE Technologies is a Swiss manufacturer of cyberware. MoorE is known for their full-body conversions, amongst their clientele is celebrity Lizzy Wizzy.",
    ["stockInfo_NCorp"] = "Night Corporation is headquartered in Night City. The company is the largest contractor of public procurements within the boundaries of the city, building and renovating facilities such as roads, bridges, tunnels, metro lines, power plants, net transmitters, waterworks, and sewerage.",
    ["stockInfo_NCPD"] = "The Night City Police Department (NCPD) is the official, privately-owned law enforcement agency of Night City. The police force's official sponsor is Night Corp, but the NCPD is also beholden to the interests of Arasaka and Militech.",
    ["stockInfo_Netwatch"] = "NetWatch is a worldwide net policing organization based out of London, England. After the DataKrash, it tries to contain dangerous AIs and secure what it can from the Old NET. It works closely with corporations and often fights against rival Netrunners.",
    ["stockInfo_NN54"] = "Network News 54, is an American media Megacorporation that broadcasts throughout the NUSA. Network 54 has held a monopoly operating on the same frequency across the entire country since 2010, when it amassed control of over 62% of all American broadcasting, and produces news, films, and television shows.",
    ["stockInfo_Orbital Air"] = "Orbital Air is a Megacorporation based out of Nairobi, Kenya that specializes in cargo and passenger transport to Earth orbit. The Aerospace giant holds a monopoly on orbital transportation with other headquarters being located in the NUSA, France, Germany, Japan, and China.",
    ["stockInfo_Petrochem"] = "Petrochem is a megacorporation whose primary focus is the petrochemical industry. Petrochem is the world's largest producer of the synthetic alcohol fuel CHOOH2 (License from Biotechnica), the primary fuel source for the mid-21st century. Petrochem control millions of acres of arable land across the NUSA.",
    ["stockInfo_QianT"] = "QianT is a manufacturer of high-end cyberware owned by Kang Tao. Although QianT was mostly used by Kang Tao as a shell company to handle sensitive operations that they themselves could not be publicly associated with.",
    ["stockInfo_Quadra"] = "Quadra manufactures retro stylized sports automotive vehicles for the general public consumer-base. The company excels at designing and building muscle cars, such as the Type-66 or their most iconic Turbo-R.",
    ["stockInfo_Raven"] = "Raven Microcybernetics, is a corporation dedicated to the cyberware business. Its headquarters are found in Night City. Raven Microcyb is one the main American manufacturer of cyberware, wetware and cybernetic electronics, and is known for always surfing the cutting edge of cybertechnology.",
    ["stockInfo_Rayfield"] = "Rayfield manufactures luxury vehicles, being known for their quality sports cars and limousines. Cutting-edge technologies are also utilized in the production of their vehicles, such as CrystalDome. The corporation's flagship vehicle is the Aerondight.",
    ["stockInfo_Thorton"] = "Thorton is company recognized for their wide array of utility vehicles, including pickup trucks or wagons. They are also known for their midclass passenger cars, most of which were first produced and released between 2020 and 2050.",
    ["stockInfo_Trauma Team"] = "Trauma Team International is a corporation that specializes in rapid response medical services. As the premium paramedical franchise, Trauma Team is one of the most notable corporations of the 21st century.TTI partners with many corporations such as Arasaka, Militech, Night Corp, Biotechnica, or Kiroshi.",
    ["stockInfo_Tsunami"] = "Tsunami Defense Systems is one of the four largest weapons manufacturers located in Japan and is considered one of the top-tier weapons manufacturers in the world. They to desig and produce weaponry and weapons paraphernalia for solos and corporate militaries alike.",
    ["stockInfo_WNS"] = "World News Service (WNS) is a MediaCorp reporting news from around world based in London, England. WNS keeps tabs on the world, by any means possible. Newspapers and news stations around the world pay large amounts of money to receive WNS stories via the WorldSat Network.",
    ["stockInfo_Zetatech"] = "Zetatech is among the number corporations that specializes in wetware and computer hardware and software design. They have always maintained a strong presence in Night City. Their products include everything from cyberware, to cyberdecks, to computers."
}

return localization