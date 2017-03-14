//
//  BellaDatiSDKTests.swift
//  BellaDatiSDKTests
//
//  Created by Martin Trgina on 2/13/17.
//  Copyright © 2017 BellaDati Inc. All rights reserved.
//

import XCTest

@testable import BellaDatiSDK

class BellaDatiSDKTests: XCTestCase {
    
    var reports = Reports()
    var chart = LineChart()
    var piechart = PieChart()
    var kpilabel = KpiLabel()
    var table = Table()
    var datasetdetail:DataSetDetail?
    var datasetData:DataSetData?
    var domain = Domain()
    
    
     // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        /* APIClient is singleton. First step is. Prior to the APIClient.sharedInstance.authenticateWithBellaDati(). User has to set the credentials */
        
        APIClient.sharedInstance.setAPIClient(scheme:"https",host:"service.belladati.com",port:443,base_url:"/api",relativeAccessTokenUrl:"/oauth/accessToken", oauth_consumer_key:"", x_auth_username:"" ,x_auth_password: "")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /* Next step is to call APIClient.sharedInstance.authenticateWithBellaDati. However This method is automatically called in Reports method downloadListOfReports. But it is important to have right setup of credentials via APIClient.sharedInstance.setAPIClient */
    
    func testAuthenticateWithBellaDati() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expect = self.expectation(description: "Framework should authenticate with BellaServer")
        
        if (!APIClient.sharedInstance.hasAccessTokenSaved())
        {
            APIClient.sharedInstance.authenticateWithBellaDati(){(error) -> Void in
                print("handlin stuff")
                if let receivedError = error
                {
                    print(receivedError)
                }
                
                expect.fulfill()
                
               
            }
            
            self.waitForExpectations(timeout: 60.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
            }

        }
            
        
        else
        {
            
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be already stored on the device. ")
            print (" I am ready to send requests")
        }
        
        
        
        
    }
    
    
    /*How to load the reports test. Reports must be loaded prior to loading Views (Tabels,KPILabel,Charts)*/
    
    func OfReports(){
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        
        reports.downloadListOfReports(filter: "TabelTestDrillDown", offset: nil, size: nil) { () -> () in
            
            
            for report in self.reports.reportDetails! {
                
                report.downloadReportDetail(completion: {
                    print(report.name)
                    print("This is name of Chart:" + report.views![0].viewName!)
                    print("This is id of ChartView:" + String(report.views![0].viewId!))
                    self.chart.viewId = report.views![0].viewId!
                    
                    self.chart.downloadOnLineChart(completion: {
                        
                        print("Color of tooltip is:" + self.chart.tooltip.background)
                        print("Color of chart background is:" + self.chart.bg_color!)
                        
                        expect.fulfill()
                    })
                    
                  

                })
                
                
            }
            
                     }


        self.waitForExpectations(timeout: 7.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        }
    

    
}
    
    /* How to load the KPI Label. On BellaDati server has to exist 1 report named KPILabel Test and has to have 1 View to keep same results for test */
    
    func OfKpiLabel(){
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        
        reports.downloadListOfReports(filter: "Pay How You Drive - Driver Overview - NEW", offset: nil, size: nil) { () -> () in
            
            
            for report in self.reports.reportDetails! {
                
                report.downloadReportDetail(completion: {
                    
                    
                    print("This is name of View:" + report.views![0].viewName!)
                    print("This is id of KPILabelView:" + String(report.views![0].viewId!))
                    self.kpilabel.viewId = "48328-rCtBF5PraV" //report.views![0].viewId!
                    
                    self.kpilabel.downloadOnLineKpiLabel(completion: {
                        
                        print("These are values of KPILabels:")
                        
                        for value in self.kpilabel.values!{
                            
                            print("Number value:"+" "+value.numberValue)
                            print("Caption:"+" "+value.caption)
                            print("Symbol:"+" "+value.symbol)
                            print("Symbol value:"+" "+value.symbolValue)
                            print("Font weight:"+" "+value.fontweight)
                            
                            
                            var backgroundcolor = String(describing: value.backgroundcolor)
                            var color = String(describing: value.backgroundcolor)
                            
                            print("Background UIColor:"+" "+backgroundcolor)
                            print("Color UIColor:"+" "+color)

                            
                        }
                        
                        
                        
                        expect.fulfill()
                    })
                    
                    
                    
                })
                
                
            }
            
        }
        
        
        self.waitForExpectations(timeout: 7.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        }

        
        
    }
    
    
    
    /*How to get data from cells in table.From header and from body. How to identify header cells in body rows*/
    
    func OfTables(){
        
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        
        reports.downloadListOfReports(filter: "Crash Data Set Overview", offset: nil, size: nil) { () -> () in
            
            
            for report in self.reports.reportDetails! {
                
                report.downloadReportDetail(completion: {
                    print(report.name)
                    print("This is name of View:" + report.views![0].viewName!)
                    print("This is id of TabelView:" + String(report.views![0].viewId!))
                    self.table.viewId = report.views![0].viewId! // keep 1 view per report to make tests easy
                    
                    self.table.downloadOnLineTable(completion: {
                        
                        
                        print("Values in Table header:")
                        
                        for row in self.table.header {
                            
                            for cell in row.cells {
                                
                                print(cell.value!)
                                print(cell.colspan)
                                print(cell.rowspan)
                                print(cell.index) // position of cell in the row
                                print(cell.drillDownLevel) //should you plus sign for drilldown, ddLevel  = 0 as default
                                print(cell.color)
                                print(cell.backgroundcolor)
                                
                            }
                        }
                        
                        print("Values in Table body:")
                        
                        for row in self.table.body {
                            
                            for cell in row.cells {
                                print(cell.value)
                                print(cell.type) // is this header cell in the row. should render apply special treatment
                            }
                        }
                        
                        


                        
                        
                      expect.fulfill()
                        
                    })
                    
                    
                    
                })
                
                
            }
        }
        
        self.waitForExpectations(timeout: 15.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        }

        
            }
    
    /*How get the datasets attributes using dataset id from report*/
    
    func ofDataSets(){
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        
        reports.downloadListOfReports(filter: "Crash Data Set Overview", offset: nil, size: nil) { () -> () in
            
            
            for report in self.reports.reportDetails! {
                
                report.downloadReportDetail(completion: {
                    
                    
            var datasetid = String(describing:report.dataSet?.id)
            print("This is id of dataset used by report:" + datasetid)
                    
            self.datasetdetail = DataSetDetail(id: (report.dataSet?.id)!)
                    
                    
                    self.datasetdetail?.downloadDataSetDetail(id: (report.dataSet?.id)!,completion: {
                        
                        
                        for attribute in (self.datasetdetail?.attributes)! {
                            
                           print(attribute.code)
                        }
                        
                        
                        
                        
                        
                        expect.fulfill()
                    })
                    
                    
                    
                })
                
                
            }
            
        }
        
        
        self.waitForExpectations(timeout: 7.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        }
       
        
    }
    
    /* - How to load L_ATTRIBUTE and M_INDICATOR data from dataSet. Assumption = DATA SET ID is already known
       - Assumption we know L_ATTRIBUTE value to use in the filter
       - How to get attribute for filter
       - How to set filter for downloadData 
       - For typeop and dateop, codeop values please see http://support.belladati.com/techdoc/Types+and+enumerations#Typesandenumerations-Filteroperationtype
       */
    
    func testOfDataSetData() {
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        self.datasetData = DataSetData()
        
        //Getting typevalues of L_ATTRIBUTE example code
        
        self.datasetdetail = DataSetDetail(id:32949)
        var L_TYPE:String?
        
        self.datasetdetail?.downloadDataSetDetail(id:datasetdetail!.id,completion: {
            
            
            for attribute in (self.datasetdetail?.attributes)! {
                
                if attribute.code == "L_ID" {
                    print("Code of attribute:" + attribute.type!)
                    L_TYPE = attribute.type!
                }
                
               
                
                
            }

        
        
            //Preparing filter "L_ATTRIBUTE
        
        
            let dataSetDataFiltr = self.datasetData?.prepareFilter(code: "L_ID", codeop: "EQ", codevalue: "10", typevalues: [L_TYPE!], typeop: "IN", dateop: "NOT_NULL")
        
         print ("Filter parameter:" + dataSetDataFiltr!)
        
            //Loading data for dataset using filter
        
        self.datasetData?.downloadData(id:self.datasetdetail!.id,filter:dataSetDataFiltr!,offset:nil,size:"4",order:nil,completion: {
          
            for row in (self.datasetData?.rows)!{
                
                
                if let value = row["L_ID"] {
                    print("L_ID VALUE IS:" + value)
                }
                
            }
            
            expect.fulfill()

        })
        })

        
        self.waitForExpectations(timeout: 50.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        
    }
    }
    
    
    /*How to load PIE Chart data*/
    
    func OfPieChart(){
        
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        piechart.viewId = "48326-GE0lbAxZOu"
        piechart.downloadOnLineChart { 
            for element in self.piechart.elements! {
                
                for item in element.values {
                    
                    print("Slice value:" + String(item.value))
                    print("Tip value:" + String(item.tip))
                }
                
                for colorofslice in element.colors!{
                    
                    print("Slicecolor:" + colorofslice)
                }
            }
            expect.fulfill()
        }
        
        self.waitForExpectations(timeout: 50.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")
        
    }
    
    
}
    /*How to get info about domain and parameters of domain. Direct domain ID insertion*/ 
 
    func OfDomain(){
        let expect = self.expectation(description: "Expected number of reports should be downloaded")
        
        domain.downloadInfo(domainId:"8333") {
            
            for (value,key) in self.domain.parameters! {
                
                print(value,key)
            }
            
           expect.fulfill()
        }
        self.waitForExpectations(timeout: 50.0) { error in
            let token = APIClient.sharedInstance.hasAccessTokenSaved()
            XCTAssertTrue(token == true,"Token should be received from BellaServ and stored on device.")

    }
    }
}
