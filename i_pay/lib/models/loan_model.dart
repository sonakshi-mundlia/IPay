class LoanInfo {
  final String name;
  final String image;
  final String loanAmount;
  final String monthlyEMI;
  final String loanPeriod;
  final String interestRate;
  final List<String> documents;
  final List<String> eligibility;
  final int minCreditScore; // NEW: Minimum CIBIL score required

  LoanInfo({
    required this.name,
    required this.image,
    required this.loanAmount,
    required this.monthlyEMI,
    required this.loanPeriod,
    required this.interestRate,
    required this.documents,
    required this.eligibility,
    this.minCreditScore = 700, // Default to 700 if not specified
  });

  static final List<LoanInfo> loanList = [
    // ------------------------ HOME LOAN ------------------------
    LoanInfo(
      name: "Home Loan",
      image: "assets/images/home.jpg",
      loanAmount: "₹2,00,000 – ₹5,00,00,000",
      monthlyEMI: "₹8,000 – ₹1,20,000",
      loanPeriod: "5 – 30 years",
      interestRate: "8.30% – 9.50% per annum",
      documents: [
        "Aadhaar & PAN",
        "3–6 months salary slips",
        "Bank statements (6 months)",
        "2 years ITR",
        "Property documents",
      ],
      eligibility: [
        "Age 21 – 65 years",
        "Stable income",
        "Credit score 700+",
        "Property valuation approval",
      ],
      minCreditScore: 700,
    ),

    // ------------------------ CAR LOAN ------------------------
    LoanInfo(
      name: "Car Loan",
      image: "assets/images/car.jpg",
      loanAmount: "₹1,00,000 – ₹30,00,000",
      monthlyEMI: "₹3,000 – ₹40,000",
      loanPeriod: "1 – 7 years",
      interestRate: "8.50% – 11.50% per annum",
      documents: [
        "Aadhaar + PAN",
        "Income proof",
        "6 months bank statement",
        "Car quotation/invoice",
      ],
      eligibility: [
        "Age 21 – 65 years",
        "Income ₹15,000+ per month",
        "Credit score 700+",
      ],
      minCreditScore: 700,
    ),

    // ------------------------ PERSONAL LOAN ------------------------
    LoanInfo(
      name: "Personal Loan",
      image: "assets/images/personal.jpg",
      loanAmount: "₹50,000 – ₹40,00,000",
      monthlyEMI: "₹2,500 – ₹1,00,000",
      loanPeriod: "1 – 6 years",
      interestRate: "10.50% – 24% per annum",
      documents: [
        "Aadhaar + PAN",
        "Salary slips",
        "Bank statements",
        "Optional: ITR",
      ],
      eligibility: [
        "Age 21 – 58 years",
        "Credit score 700+",
        "Stable salary income",
      ],
      minCreditScore: 700,
    ),

    // ------------------------ EDUCATION LOAN ------------------------
    LoanInfo(
      name: "Education Loan",
      image: "assets/images/education.jpg",
      loanAmount: "₹1,00,000 – ₹50,00,000",
      monthlyEMI: "₹3,000 – ₹60,000",
      loanPeriod: "5 – 15 years",
      interestRate: "8.40% – 12.50% per annum",
      documents: [
        "Aadhaar + PAN",
        "Admission letter",
        "Fee structure",
        "Co-applicant KYC",
        "Parent income proof",
      ],
      eligibility: [
        "Indian citizen",
        "Admission to recognized institution",
        "Co-applicant required",
      ],
      minCreditScore: 650, // Lower score for education loans
    ),

    // ------------------------ BUSINESS LOAN ------------------------
    LoanInfo(
      name: "Business Loan",
      image: "assets/images/business.jpg",
      loanAmount: "₹50,000 – ₹2,00,00,000",
      monthlyEMI: "₹2,000 – ₹2,00,000",
      loanPeriod: "1 – 10 years",
      interestRate: "11% – 22% per annum",
      documents: [
        "GST certificate / MSME",
        "GST returns",
        "Bank statements",
        "2–3 years ITR",
      ],
      eligibility: [
        "Age 21 – 65",
        "Business vintage 1–3 years",
        "Good cash flow",
      ],
      minCreditScore: 700,
    ),

    // ------------------------ GOLD LOAN ------------------------
    LoanInfo(
      name: "Gold Loan",
      image: "assets/images/gold.jpg",
      loanAmount: "₹10,000 – ₹50,00,000",
      monthlyEMI: "₹500 – ₹1,00,000",
      loanPeriod: "6 months – 5 years",
      interestRate: "7.5% – 16% per annum",
      documents: [
        "Aadhaar OR PAN",
        "Photograph",
      ],
      eligibility: [
        "Age 18 – 75",
        "Gold of 18K–24K purity",
      ],
      minCreditScore: 650,
    ),

    // ------------------------ LOAN AGAINST PROPERTY ------------------------
    LoanInfo(
      name: "Loan Against Property",
      image: "assets/images/property.jpg",
      loanAmount: "₹5,00,000 – ₹10,00,00,000",
      monthlyEMI: "₹10,000 – ₹3,00,000",
      loanPeriod: "5 – 20 years",
      interestRate: "9.5% – 14% per annum",
      documents: [
        "Property papers",
        "KYC documents",
        "Income proof + ITR",
        "Bank statements",
      ],
      eligibility: [
        "Age 23 – 65",
        "Clear ownership of property",
        "Credit score 700+",
      ],
      minCreditScore: 700,
    ),
  ];
}
