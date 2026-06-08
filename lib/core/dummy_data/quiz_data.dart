import '../models/quiz_models.dart';

class QuizData {
  static const List<QuizModule> defaultModules = [
    QuizModule(
      id: 'budgeting',
      title: 'Budgeting Basics',
      description: 'Learn how to plan and track your income and expenses to achieve financial stability.',
      iconName: 'wallet',
      gradientColorsValues: [0xFF6366F1, 0xFF4F46E5],
      lessonText: 'A budget is a roadmap for your money. By using rules like the 50/30/20 rule (50% needs, 30% wants, 20% savings), you ensure that your essential expenses are covered while still building your savings and enjoying your life. Tracking every expense helps prevent overspending.',
      keyTakeaways: [
        'A budget tracks income vs. expenses.',
        'The 50/30/20 rule divides money into Needs, Wants, and Savings.',
        'Tracking prevents accidental overspending.'
      ],
      sortOrder: 1,
    ),
    QuizModule(
      id: 'saving',
      title: 'The Art of Saving',
      description: 'Build a solid emergency fund and secure your financial safety net.',
      iconName: 'savings',
      gradientColorsValues: [0xFF10B981, 0xFF059669],
      lessonText: 'Saving is about keeping money safe for future needs. An emergency fund is the cornerstone of personal finance, representing 3 to 6 months of living expenses. It protects you from high-interest debt when unexpected events, like medical emergencies or job loss, happen.',
      keyTakeaways: [
        'An emergency fund is a financial safety net.',
        'Save 3 to 6 months of living expenses.',
        'Keeps you out of debt when emergencies strike.'
      ],
      sortOrder: 2,
    ),
    QuizModule(
      id: 'stock_market',
      title: 'Stock Market Intro',
      description: 'Demystify shares, corporate ownership, and how public listings work.',
      iconName: 'chart',
      gradientColorsValues: [0xFFF59E0B, 0xFFD97706],
      lessonText: 'Buying a stock means purchasing a tiny fraction of ownership in a company. When the company grows and earns profits, the value of your shares increases, and they may pay out dividends. Companies go public through an Initial Public Offering (IPO) to raise capital from everyday investors.',
      keyTakeaways: [
        'Stocks represent partial company ownership.',
        'Dividends are payouts of company profits.',
        'IPOs let companies sell shares to the public.'
      ],
      sortOrder: 3,
    ),
    QuizModule(
      id: 'investing_basics',
      title: 'Investing 101',
      description: 'Differentiate saving from investing and understand asset classes.',
      iconName: 'trending',
      gradientColorsValues: [0xFFEC4899, 0xFFDB2777],
      lessonText: 'While saving preserves capital with low risk, investing aims to build long-term wealth by purchasing assets like stocks, bonds, or real estate. Investing involves higher risk and volatility, but historically delivers much higher returns than a standard bank savings account.',
      keyTakeaways: [
        'Saving preserves cash; investing grows wealth.',
        'Investing involves risk and market fluctuations.',
        'Stocks and real estate are common investment assets.'
      ],
      sortOrder: 4,
    ),
    QuizModule(
      id: 'risk_return',
      title: 'Risk & Return',
      description: 'Learn the core balance between financial risk and potential rewards.',
      iconName: 'balance',
      gradientColorsValues: [0xFF8B5CF6, 0xFF7C3AED],
      lessonText: 'The risk-return tradeoff is a fundamental financial principle: higher potential returns always require accepting higher risk of loss. Low-risk investments like government bonds offer safety but lower returns, whereas stocks offer higher potential gains along with higher price volatility.',
      keyTakeaways: [
        'Risk and return are directly related.',
        'High potential return requires high risk tolerance.',
        'Bonds are lower risk; stocks are higher risk.'
      ],
      sortOrder: 5,
    ),
    QuizModule(
      id: 'diversification',
      title: 'Diversification',
      description: 'Spread your eggs across multiple baskets to mitigate unsystematic risk.',
      iconName: 'grid',
      gradientColorsValues: [0xFF06B6D4, 0xFF0891B2],
      lessonText: 'Diversification is the practice of spreading your investments across various assets, sectors, and geographic regions. By doing so, a decline in one single company or sector won\'t devastate your entire portfolio. It is the most effective way to reduce company-specific (unsystematic) risk.',
      keyTakeaways: [
        'Diversification reduces company-specific risk.',
        'Avoid putting all your funds in one place.',
        'Spreads capital across assets and industries.'
      ],
      sortOrder: 6,
    ),
    QuizModule(
      id: 'inflation',
      title: 'Inflation Explained',
      description: 'See how inflation erodes purchasing power and how to hedge against it.',
      iconName: 'toll',
      gradientColorsValues: [0xFFEF4444, 0xFFDC2626],
      lessonText: 'Inflation is the gradual increase in prices over time, which reduces the purchasing power of your money. If your savings interest rate is lower than inflation, you are effectively losing money. Investing in assets like equities and real estate has historically been an excellent inflation hedge.',
      keyTakeaways: [
        'Inflation erodes the purchasing power of money.',
        'Cash in savings accounts loses value to inflation.',
        'Stocks and real estate historically beat inflation.'
      ],
      sortOrder: 7,
    ),
    QuizModule(
      id: 'compound_interest',
      title: 'Compound Interest',
      description: 'Discover the exponential power of earning interest on your interest.',
      iconName: 'stars',
      gradientColorsValues: [0xFF14B8A6, 0xFF0D9488],
      lessonText: 'Compound interest is when you earn interest on both your original principal and the interest accumulated over time. This creates a snowball effect where your wealth grows exponentially. The Rule of 72 helps estimate doubling time: divide 72 by your annual interest rate.',
      keyTakeaways: [
        'Earn interest on principal AND prior interest.',
        'Creates exponential wealth growth over time.',
        'The Rule of 72 estimates investment doubling time.'
      ],
      sortOrder: 8,
    ),
    QuizModule(
      id: 'pe_ratio',
      title: 'Valuation & P/E',
      description: 'Learn how to evaluate if a stock is cheap or expensive.',
      iconName: 'analytics',
      gradientColorsValues: [0xFF6B7280, 0xFF4B5563],
      lessonText: 'The Price-to-Earnings (P/E) ratio compares a company\'s stock price to its earnings per share. A high P/E ratio indicates that investors expect high growth in the future or that the stock is currently overvalued. A low P/E can mean a company is undervalued or in trouble.',
      keyTakeaways: [
        'P/E compares stock price to its earnings.',
        'High P/E suggests high growth or overvaluation.',
        'Low P/E can mean undervaluation or distress.'
      ],
      sortOrder: 9,
    ),
    QuizModule(
      id: 'roe',
      title: 'ROE Profitability',
      description: 'Analyze how efficiently a company turns equity into earnings.',
      iconName: 'pie_chart',
      gradientColorsValues: [0xFFF43F5E, 0xFFE11D48],
      lessonText: 'Return on Equity (ROE) measures a corporation\'s profitability by showing how much profit a company generates with the money shareholders have invested. An ROE of 15-20% is generally considered strong, indicating highly efficient corporate management.',
      keyTakeaways: [
        'ROE measures efficiency of shareholder capital usage.',
        'Calculated as Net Income divided by Equity.',
        'Higher ROE signifies superior profit generation.'
      ],
      sortOrder: 10,
    ),
    QuizModule(
      id: 'mutual_funds',
      title: 'Mutual Funds',
      description: 'Explore pooled investment vehicles managed by finance professionals.',
      iconName: 'groups',
      gradientColorsValues: [0xFF78716C, 0xFF57534E],
      lessonText: 'A mutual fund pools money from many individual investors to purchase a broad, diversified portfolio of stocks, bonds, or other securities. These portfolios are managed by professional fund managers, making them an excellent hands-off choice for beginners seeking instant diversification.',
      keyTakeaways: [
        'Mutual funds pool money from multiple investors.',
        'Managed by financial professionals.',
        'Provides instant, affordable diversification.'
      ],
      sortOrder: 11,
    ),
    QuizModule(
      id: 'cryptocurrency',
      title: 'Crypto & Blockchain',
      description: 'Understand digital assets and decentralized ledger technology.',
      iconName: 'bitcoin',
      gradientColorsValues: [0xFF84CC16, 0xFF65A30D],
      lessonText: 'Cryptocurrencies are digital, decentralized currencies built on blockchain technology. Unlike traditional money, they are not issued or backed by any government or central bank. They offer high potential returns but come with extreme volatility and unique security risks.',
      keyTakeaways: [
        'Decentralized digital currencies.',
        'Powered securely by blockchain technology.',
        'Carries extreme price volatility and unique risks.'
      ],
      sortOrder: 12,
    ),
  ];

  static const List<QuizQuestion> defaultQuestions = [
    // 1. budgeting
    QuizQuestion(
      id: 'q_budgeting_001',
      question: 'What is the primary purpose of a personal budget?',
      options: [
        'To plan and track income and expenses',
        'To completely stop all personal spending',
        'To calculate government taxes',
        'To replace a traditional bank account'
      ],
      correctIndex: 0,
      explanation: 'A budget is a plan that helps you track your income and align it with your expenses, saving, and financial goals.',
      topic: 'budgeting',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_budgeting_002',
      question: 'Which budgeting method divides your post-tax income into 50% needs, 30% wants, and 20% savings?',
      options: [
        'The 50/30/20 Rule',
        'Zero-Based Budgeting',
        'The Envelope System',
        'The Pay-Your-First Method'
      ],
      correctIndex: 0,
      explanation: 'The 50/30/20 rule is a simple framework: 50% for essential needs, 30% for personal wants, and 20% for savings and debt payoff.',
      topic: 'budgeting',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_budgeting_003',
      question: 'What is the core principle of zero-based budgeting?',
      options: [
        'Every single dollar of income is assigned to a specific category, leaving zero unallocated',
        'A method where you try to spend zero dollars for an entire month',
        'Only spending money on items that cost zero dollars after discounts',
        'Resetting your bank account balance to zero at the end of each year'
      ],
      correctIndex: 0,
      explanation: 'In zero-based budgeting, your income minus your expenses and savings equals zero, ensuring that every dollar has a specific job.',
      topic: 'budgeting',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_budgeting_004',
      question: 'What is typically categorized as a "need" under the 50/30/20 rule?',
      options: [
        'Rent or mortgage payments',
        'Monthly premium streaming subscriptions',
        'Dining out at fancy restaurants',
        'Buying the latest designer shoes'
      ],
      correctIndex: 0,
      explanation: 'Needs are essential expenses required for basic survival and shelter, such as housing rent, basic utilities, and groceries.',
      topic: 'budgeting',
      difficulty: 'beginner',
      active: true,
    ),

    // 2. saving
    QuizQuestion(
      id: 'q_saving_001',
      question: 'What is the main purpose of an emergency fund?',
      options: [
        'To cover unexpected financial emergencies or job loss',
        'To buy luxury goods and go on vacations',
        'To invest in highly volatile, high-return stocks',
        'To increase your credit card limit'
      ],
      correctIndex: 0,
      explanation: 'An emergency fund acts as a financial safety net to cover unexpected expenses like medical bills, car repairs, or sudden job loss without going into debt.',
      topic: 'saving',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_saving_002',
      question: 'How much living expenses do financial planners typically recommend saving in an emergency fund?',
      options: [
        '3 to 6 months of expenses',
        '1 to 2 weeks of expenses',
        '12 to 24 months of expenses',
        'No specific amount is recommended'
      ],
      correctIndex: 0,
      explanation: 'While it depends on personal circumstances, financial experts widely recommend saving 3 to 6 months of living expenses in an emergency fund.',
      topic: 'saving',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_saving_003',
      question: 'Which of the following accounts offers the highest liquidity for an emergency fund?',
      options: [
        'High-Yield Savings Account (HYSA)',
        'Real estate property holdings',
        'A 5-year Certificate of Deposit (CD)',
        'Cryptocurrency hardware wallet'
      ],
      correctIndex: 0,
      explanation: 'A High-Yield Savings Account allows immediate access to cash with minimal/no penalties, making it highly liquid for emergencies.',
      topic: 'saving',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_saving_004',
      question: 'What is the primary benefit of automating your savings?',
      options: [
        'It removes the temptation to spend by saving money before you can use it',
        'It guarantees higher interest rates from the bank',
        'It eliminates all inflation risks',
        'It completely removes the need to pay taxes on interest earned'
      ],
      correctIndex: 0,
      explanation: 'Automating savings ensures consistency by moving money directly to your savings account on payday (paying yourself first) before it can be spent.',
      topic: 'saving',
      difficulty: 'beginner',
      active: true,
    ),

    // 3. stock_market
    QuizQuestion(
      id: 'q_stock_market_001',
      question: 'What does buying a stock represent?',
      options: [
        'Partial ownership of the company',
        'A loan made to the company',
        'A government savings bond',
        'A contract guaranteeing a profit'
      ],
      correctIndex: 0,
      explanation: 'A stock (or share) represents a unit of ownership in a corporation, giving you a claim on its assets and earnings.',
      topic: 'stock_market',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_stock_market_002',
      question: 'What is an Initial Public Offering (IPO)?',
      options: [
        'The first time a company sells its shares to the public',
        'An internal corporate tax audit',
        'The merger of two major private companies',
        'A bank loan application process'
      ],
      correctIndex: 0,
      explanation: 'An IPO is the process where a private company offers shares to the public for the first time to raise capital.',
      topic: 'stock_market',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_stock_market_003',
      question: 'What is a stock market index, such as the S&P 500?',
      options: [
        'A basket of stocks representing a section of the stock market to track performance',
        'A database containing the contact details of all corporate CEOs',
        'A calculator used to determine daily stock transaction fees',
        'A government agency that regulates stock trading'
      ],
      correctIndex: 0,
      explanation: 'A stock index tracks the performance of a selected group of stocks, providing a benchmark for the health of the overall market or specific sectors.',
      topic: 'stock_market',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_stock_market_004',
      question: 'What does selling a stock "short" mean?',
      options: [
        'Borrowing a stock to sell it, hoping its price declines so you can buy it back cheaper',
        'Selling a stock within 5 minutes of purchasing it',
        'Selling a stock at a discount to close friends',
        'Dividing your stock ownership into smaller pieces'
      ],
      correctIndex: 0,
      explanation: 'Short selling involves borrowing shares and selling them, planning to buy them back later at a lower price to return them, pocketing the price difference as profit.',
      topic: 'stock_market',
      difficulty: 'beginner',
      active: true,
    ),

    // 4. investing_basics
    QuizQuestion(
      id: 'q_investing_basics_001',
      question: 'What is the primary difference between saving and investing?',
      options: [
        'Investing aims to grow wealth over time but carries risk; saving is low-risk capital preservation',
        'Saving is only for wealthy individuals',
        'Investing is always short-term; saving is always long-term',
        'There is no functional difference between them'
      ],
      correctIndex: 0,
      explanation: 'Saving focuses on preserving cash securely, whereas investing puts capital into assets (like stocks or real estate) to achieve higher growth, accepting higher risks.',
      topic: 'investing_basics',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_investing_basics_002',
      question: 'Which of the following is generally considered the most volatile asset class?',
      options: [
        'Stocks',
        'Government Bonds',
        'Savings Accounts',
        'Certificates of Deposit (CDs)'
      ],
      correctIndex: 0,
      explanation: 'Stocks generally exhibit higher price volatility (fluctuation) compared to government bonds, CDs, and savings accounts.',
      topic: 'investing_basics',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_investing_basics_003',
      question: 'What are bonds in the context of investing?',
      options: [
        'Debt securities where you loan money to a government or corporation in exchange for interest',
        'Contracts that legally bind two business partners together',
        'Insurance policies that protect you against stock market crashes',
        'Vouchers that can be redeemed for physical gold'
      ],
      correctIndex: 0,
      explanation: 'Bonds are debt instruments representing a loan made by an investor to a borrower. The borrower pays periodic interest (coupon) and returns the principal at maturity.',
      topic: 'investing_basics',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_investing_basics_004',
      question: 'What is Dollar-Cost Averaging (DCA)?',
      options: [
        'Investing a fixed amount of money at regular intervals regardless of the asset\'s price',
        'Converting all your investment assets into US Dollars',
        'Only buying stocks when they cost exactly one dollar',
        'Calculating the average price of all stocks listed on an exchange'
      ],
      correctIndex: 0,
      explanation: 'DCA is a strategy where you invest a fixed amount regularly, which buys more shares when prices are low and fewer shares when prices are high, smoothing out volatility.',
      topic: 'investing_basics',
      difficulty: 'beginner',
      active: true,
    ),

    // 5. risk_return
    QuizQuestion(
      id: 'q_risk_return_001',
      question: 'In finance, what is the risk-return tradeoff?',
      options: [
        'Higher potential returns are generally associated with higher investment risk',
        'Higher risk always guarantees a higher return',
        'Low-risk investments always lose money due to inflation',
        'Risk and return are completely unrelated'
      ],
      correctIndex: 0,
      explanation: 'The risk-return tradeoff is the principle that potential return rises with an increase in risk. There is no guarantee, but higher returns require accepting more risk.',
      topic: 'risk_return',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_risk_return_002',
      question: 'Which type of risk can be reduced through diversification?',
      options: [
        'Unsystematic (company-specific) risk',
        'Systematic (market) risk',
        'Inflation risk',
        'Interest rate risk'
      ],
      correctIndex: 0,
      explanation: 'Unsystematic risk, which is specific to a company or industry, can be reduced through diversification by holding a variety of assets.',
      topic: 'risk_return',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_risk_return_003',
      question: 'Which investment type typically offers the lowest risk and lowest potential return?',
      options: [
        'Treasury Bills (T-Bills)',
        'Small-cap growth stocks',
        'Corporate high-yield bonds',
        'Real estate development projects'
      ],
      correctIndex: 0,
      explanation: 'Treasury Bills are backed by the full faith and credit of the government, making them virtually risk-free, but they offer lower interest yields.',
      topic: 'risk_return',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_risk_return_004',
      question: 'What does "risk tolerance" refer to?',
      options: [
        'An investor\'s emotional and financial ability to handle market declines and volatility',
        'The legal maximum amount of money you are allowed to lose',
        'The percentage of transaction fees charged by a brokerage',
        'A measurement of how likely a company is to declare bankruptcy'
      ],
      correctIndex: 0,
      explanation: 'Risk tolerance is an individual\'s capacity to endure swings in the value of their investments. It depends on age, goals, timeline, and emotional comfort with risk.',
      topic: 'risk_return',
      difficulty: 'beginner',
      active: true,
    ),

    // 6. diversification
    QuizQuestion(
      id: 'q_diversification_001',
      question: 'What is the primary goal of portfolio diversification?',
      options: [
        'To minimize overall investment risk by spreading assets',
        'To guarantee a positive return on every investment',
        'To concentrate capital on a single high-performing stock',
        'To completely eliminate market volatility'
      ],
      correctIndex: 0,
      explanation: 'Diversification involves spreading investments across different asset classes, industries, and geographies so that poor performance in one area doesn\'t ruin the whole portfolio.',
      topic: 'diversification',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_diversification_002',
      question: 'Which saying best describes the concept of diversification?',
      options: [
        'Don\'t put all your eggs in one basket',
        'High risk, high reward',
        'A penny saved is a penny earned',
        'Buy low, sell high'
      ],
      correctIndex: 0,
      explanation: '\'Don\'t put all your eggs in one basket\' perfectly summarizes diversification: spreading risk so a single failure doesn\'t cause total loss.',
      topic: 'diversification',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_diversification_003',
      question: 'Which of the following is NOT an effective way to diversify your portfolio?',
      options: [
        'Investing all your money in 10 different technology startups',
        'Buying a broad-market index fund or ETF',
        'Investing across stocks, bonds, and real estate',
        'Holding international stocks in addition to domestic ones'
      ],
      correctIndex: 0,
      explanation: 'Putting all capital in one sector (technology startups) exposes you to severe sector-specific risk, even if spread across 10 startups. True diversification requires spreading across multiple sectors and asset classes.',
      topic: 'diversification',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_diversification_004',
      question: 'How does diversification affect portfolio returns and risk?',
      options: [
        'It reduces risk (volatility) without necessarily sacrificing long-term expected returns',
        'It guarantees that you will never lose money in any year',
        'It multiplies your potential maximum returns by ten times',
        'It increases transaction costs without changing risk'
      ],
      correctIndex: 0,
      explanation: 'By combining assets that do not move in perfect lockstep, diversification reduces the overall volatility (risk) of the portfolio while preserving expected returns based on the asset mix.',
      topic: 'diversification',
      difficulty: 'beginner',
      active: true,
    ),

    // 7. inflation
    QuizQuestion(
      id: 'q_inflation_001',
      question: 'What is inflation?',
      options: [
        'The general increase in prices and fall in the purchasing value of money',
        'An increase in the purchasing power of a currency',
        'A decrease in corporate profit margins',
        'A special tax levied on imported goods'
      ],
      correctIndex: 0,
      explanation: 'Inflation represents the rate at which the general level of prices for goods and services rises, subsequently eroding the purchasing power of cash.',
      topic: 'inflation',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_inflation_002',
      question: 'Which asset class is historically considered a good hedge against inflation?',
      options: [
        'Real Estate and Equities (Stocks)',
        'Cash in a standard checking account',
        'Fixed-rate long-term bonds',
        'Physical currency bills'
      ],
      correctIndex: 0,
      explanation: 'Tangible assets like real estate and equities (stocks) tend to grow in value and generate returns that outpace inflation over the long term.',
      topic: 'inflation',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_inflation_003',
      question: 'How does inflation affect the purchasing power of your money over time?',
      options: [
        'It decreases purchasing power, meaning a dollar buys fewer goods',
        'It increases purchasing power, meaning a dollar buys more goods',
        'It has no effect on purchasing power',
        'It multiplies the absolute value of your cash reserves'
      ],
      correctIndex: 0,
      explanation: 'Inflation raises prices, which means each unit of currency buys a smaller percentage of a good or service.',
      topic: 'inflation',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_inflation_004',
      question: 'Which government metric is commonly used to measure consumer inflation?',
      options: [
        'Consumer Price Index (CPI)',
        'Gross Domestic Product (GDP)',
        'Standard & Poor\'s 500 (S&P 500)',
        'Federal Funds Rate'
      ],
      correctIndex: 0,
      explanation: 'The CPI measures the average change over time in the prices paid by consumers for a market basket of goods and services, representing the consumer inflation rate.',
      topic: 'inflation',
      difficulty: 'beginner',
      active: true,
    ),

    // 8. compound_interest
    QuizQuestion(
      id: 'q_compound_interest_001',
      question: 'Why is compound interest often called \'interest on interest\'?',
      options: [
        'You earn interest on your initial principal AND on previously accumulated interest',
        'It is a double tax applied to savings accounts',
        'It is interest charged on credit card debt only',
        'It is a marketing term with no mathematical basis'
      ],
      correctIndex: 0,
      explanation: 'Compound interest is calculated on the initial principal and also on the accumulated interest of previous periods, causing wealth to grow exponentially.',
      topic: 'compound_interest',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_compound_interest_002',
      question: 'Which formula represents the power of compound interest to estimate how long it takes to double your money?',
      options: [
        'The Rule of 72',
        'The 50/30/20 Rule',
        'The Rule of 100',
        'The Pythagorean Theorem'
      ],
      correctIndex: 0,
      explanation: 'The Rule of 72 is a quick way to estimate how long an investment takes to double: divide 72 by the annual interest rate.',
      topic: 'compound_interest',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_compound_interest_003',
      question: 'What is the compounding frequency, and how does it affect your savings?',
      options: [
        'How often interest is calculated; more frequent compounding leads to faster growth',
        'The number of times you withdraw money from a savings account',
        'The speed at which interest rates change in the economy',
        'How often you add new money to your initial principal'
      ],
      correctIndex: 0,
      explanation: 'The more frequently interest is compounded (e.g., daily vs. annually) and added to the balance, the more interest you earn on your interest, accelerating growth.',
      topic: 'compound_interest',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_compound_interest_004',
      question: 'If you invest \$1,000 at a 10% annual interest rate compounded annually, how much will you have after 2 years?',
      options: [
        '\$1,210',
        '\$1,200',
        '\$1,100',
        '\$1,300'
      ],
      correctIndex: 0,
      explanation: 'Year 1: \$1,000 + 10% = \$1,100. Year 2: \$1,100 + 10% (\$110) = \$1,210. (Simple interest would only yield \$1,200).',
      topic: 'compound_interest',
      difficulty: 'beginner',
      active: true,
    ),

    // 9. pe_ratio
    QuizQuestion(
      id: 'q_pe_ratio_001',
      question: 'What does the Price-to-Earnings (P/E) ratio measure?',
      options: [
        'A stock\'s price relative to its earnings per share (EPS)',
        'A company\'s total debt relative to its equity',
        'The percentage of net profit paid out as dividends',
        'The ratio of cash flow to capital expenditures'
      ],
      correctIndex: 0,
      explanation: 'The P/E ratio is a valuation metric showing how much investors are willing to pay per dollar of a company\'s current earnings.',
      topic: 'pe_ratio',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_pe_ratio_002',
      question: 'A very high P/E ratio compared to industry peers might indicate that a stock is:',
      options: [
        'Overvalued or has high expected future growth',
        'Undervalued or financially distressed',
        'Paying a high dividend yield',
        'Low risk and highly stable'
      ],
      correctIndex: 0,
      explanation: 'A high P/E ratio suggests investors expect higher earnings growth in the future, or the stock is currently overvalued.',
      topic: 'pe_ratio',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_pe_ratio_003',
      question: 'Which of the following is a key limitation of the P/E ratio?',
      options: [
        'It does not take into account a company\'s debt or cash balance',
        'It is only updated once every ten years',
        'It can only be calculated for companies in the tech sector',
        'It is always negative for profitable companies'
      ],
      correctIndex: 0,
      explanation: 'The P/E ratio ignores the balance sheet debt and cash levels, which could hide significant financial leverage or liquidity risks.',
      topic: 'pe_ratio',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_pe_ratio_004',
      question: 'What is the difference between trailing P/E and forward P/E?',
      options: [
        'Trailing P/E uses historical earnings; forward P/E uses projected future earnings',
        'Trailing P/E is for large companies; forward P/E is for small startups',
        'Trailing P/E is calculated in dollars; forward P/E is in percentages',
        'There is no difference; they are different names for the same metric'
      ],
      correctIndex: 0,
      explanation: 'Trailing P/E is based on actual earnings per share from the past 12 months, whereas forward P/E is based on analysts\' forecasts of earnings for the upcoming year.',
      topic: 'pe_ratio',
      difficulty: 'beginner',
      active: true,
    ),

    // 10. roe
    QuizQuestion(
      id: 'q_roe_001',
      question: 'What does Return on Equity (ROE) measure?',
      options: [
        'How efficiently a company generates profits from shareholders\' equity',
        'The total return on a stock\'s price over a year',
        'The percentage of debt relative to shareholder equity',
        'The total dividend payout divided by shares outstanding'
      ],
      correctIndex: 0,
      explanation: 'ROE is a profitability metric calculated by dividing net income by shareholders\' equity, showing how well a firm uses investors\' capital to generate earnings.',
      topic: 'roe',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_roe_002',
      question: 'If Company A has an ROE of 20% and Company B has an ROE of 5% in the same industry, Company A is generally:',
      options: [
        'More efficient at generating profit from shareholder capital',
        'More heavily burdened with debt',
        'Less profitable overall',
        'Offering lower dividend yields'
      ],
      correctIndex: 0,
      explanation: 'A higher ROE indicates a company is more efficient at turning shareholder investments into profits.',
      topic: 'roe',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_roe_003',
      question: 'Which formula is used to calculate Return on Equity (ROE)?',
      options: [
        'Net Income divided by Shareholders\' Equity',
        'Total Revenue divided by Total Liabilities',
        'Stock Price divided by Earnings Per Share',
        'Operating Cash Flow divided by Capital Expenditures'
      ],
      correctIndex: 0,
      explanation: 'ROE is calculated by dividing net income (annual profits) by shareholders\' equity (the assets minus liabilities owned by shareholders).',
      topic: 'roe',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_roe_004',
      question: 'Why might a company have an artificially high ROE that is actually a warning sign?',
      options: [
        'The company took on an excessive amount of debt, reducing shareholders\' equity',
        'The company\'s net income is negative',
        'The company has too many shares outstanding',
        'The company\'s stock price crashed'
      ],
      correctIndex: 0,
      explanation: 'Because Equity = Assets - Debt, a company that borrows aggressively will have a very small equity denominator, inflating ROE even if it is in high-risk financial distress.',
      topic: 'roe',
      difficulty: 'beginner',
      active: true,
    ),

    // 11. mutual_funds
    QuizQuestion(
      id: 'q_mutual_funds_001',
      question: 'What is a mutual fund?',
      options: [
        'A pool of money from many investors used to buy a diversified portfolio',
        'A special high-interest savings account at a local bank',
        'An interest-free personal loan offered by credit unions',
        'A type of insurance policy for financial losses'
      ],
      correctIndex: 0,
      explanation: 'A mutual fund aggregates money from multiple investors to purchase a diversified portfolio of stocks, bonds, or other securities managed by professionals.',
      topic: 'mutual_funds',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_mutual_funds_002',
      question: 'Who manages the portfolio of a mutual fund?',
      options: [
        'A professional fund manager',
        'A committee of the investors',
        'The central bank',
        'An automated bank teller machine'
      ],
      correctIndex: 0,
      explanation: 'Mutual funds are managed by professional fund managers who conduct research and execute buying and selling decisions according to the fund\'s goals.',
      topic: 'mutual_funds',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_mutual_funds_003',
      question: 'What is the difference between an index fund and an actively managed mutual fund?',
      options: [
        'Index funds track a market benchmark automatically; active funds have managers picking stocks',
        'Index funds only buy bonds; active funds only buy stocks',
        'Index funds are only open to bank employees',
        'Active funds are completely free of management fees'
      ],
      correctIndex: 0,
      explanation: 'Index funds passively replicate a specific index (like the S&P 500) and have low fees, whereas actively managed funds employ managers to select stocks to beat the market, carrying higher fees.',
      topic: 'mutual_funds',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_mutual_funds_004',
      question: 'What is Net Asset Value (NAV) in a mutual fund?',
      options: [
        'The price per share of the mutual fund, calculated at the end of each trading day',
        'The total number of investors currently holding shares in the fund',
        'The interest rate paid by the fund to its bank',
        'The maximum tax penalty for selling fund shares'
      ],
      correctIndex: 0,
      explanation: 'NAV represents the net value of a fund\'s assets minus its liabilities, divided by the number of shares outstanding. It is updated at the close of every business day.',
      topic: 'mutual_funds',
      difficulty: 'beginner',
      active: true,
    ),

    // 12. cryptocurrency
    QuizQuestion(
      id: 'q_cryptocurrency_001',
      question: 'What technology forms the foundation of most cryptocurrencies?',
      options: [
        'Blockchain',
        'Artificial Intelligence',
        'Quantum Computing',
        'Virtual Reality'
      ],
      correctIndex: 0,
      explanation: 'Blockchain is a decentralized ledger technology that records transactions across many computers securely and transparently.',
      topic: 'cryptocurrency',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_cryptocurrency_002',
      question: 'What is a key characteristic of Bitcoin and other cryptocurrencies?',
      options: [
        'Decentralization',
        'Backed by gold reserves',
        'Controlled by a central bank',
        'Guaranteed risk-free returns'
      ],
      correctIndex: 0,
      explanation: 'Cryptocurrencies are typically decentralized, meaning they are not controlled by a central bank or single authority, but operate on a peer-to-peer network.',
      topic: 'cryptocurrency',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_cryptocurrency_003',
      question: 'What is the process of "mining" in proof-of-work cryptocurrencies like Bitcoin?',
      options: [
        'Using computer hardware to solve complex math problems to validate transactions and earn coins',
        'Extracting physical metals from the earth to back digital tokens',
        'Searching the web for hidden promotional codes to get free coins',
        'Exchanging fiat currency for digital coins at an ATM'
      ],
      correctIndex: 0,
      explanation: 'Mining in Proof-of-Work systems involves using high-powered computers to solve cryptographic puzzles, which validates transactions, adds them to the blockchain ledger, and mints new coins.',
      topic: 'cryptocurrency',
      difficulty: 'beginner',
      active: true,
    ),
    QuizQuestion(
      id: 'q_cryptocurrency_004',
      question: 'What is a "smart contract" in blockchain networks like Ethereum?',
      options: [
        'A self-executing contract with the terms of the agreement directly written into code lines',
        'A legal document signed digitally by two lawyers',
        'An AI program that automatically predicts future stock prices',
        'A secure email communication system between crypto exchanges'
      ],
      correctIndex: 0,
      explanation: 'Smart contracts are digital agreements stored on a blockchain that execute automatically when predetermined conditions are met, eliminating the need for intermediaries.',
      topic: 'cryptocurrency',
      difficulty: 'beginner',
      active: true,
    ),
  ];
}
