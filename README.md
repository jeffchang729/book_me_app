# **數位產品矩陣與後端架構總覽**

這是一份針對 **Book Me**、**Tell Me** 與 **CoCo Daily** 三大核心產品的專案藍圖，旨在整合產品願景、功能規劃、以及統一的後端微服務架構，為下一階段的開發奠定堅實的基礎。

## **1\. 產品矩陣建構藍圖**

我們的策略是從單一專案的技術挑戰演進為一個多產品的宏觀佈局，並為不同性質的產品制定最合適的架構決策。

### **1.1 核心決策：統一後端 vs. 獨立架構**

* **建立統一後端**：針對 **TELL ME**、**BookMe**、**特價通知 App (coco Daily)** 這三個本質上為「內容驅動」的應用，我們將建立一個統一的後端伺服器，以最大化資源共用與開發效率。  
* **保持遊戲獨立**：對於 **Vampire Survivors Clone** 這類重度依賴客戶端即時運算的產品，將與內容型 App 的後端分離，可考慮採用更輕量的 Firebase 處理排行榜、雲端存檔等功能。

### **1.2 最終藍圖：一個可擴展的數位事業地基**

* **核心技術**：以 NestJS \+ GCP 微服務 為核心，搭建統一後端。  
* **服務擴展**：為「coco Daily」新增爬蟲服務 (Scraper Service) 與通知服務 (Notification Service)。  
* **開發模式**：確立前端、後端、遊戲團隊可獨立作業的平行開發路線圖。

## **2\. 三大核心產品矩陣：專案簡報**

### **2.1 BookMe：新世代的讀書社群**

* **核心理念**：打造一個專注於「書籍分享」的垂直社群平台，如同「書籍界的 Instagram」，讓分享閱讀成為一種生活品味的展現。  
* **公司願景**：成立 BookMe 公司，圍繞此核心產品建立商業模式與品牌生態。  
* **四大核心功能模組**：  
  1. **AI 推薦系統**：使用者輸入抽象概念（如「想成為更有創意的領導者」），AI 推薦書單。  
     * *商業價值*：成為使用者找書入口，並透過導購連結創造分潤營收。  
  2. **使用者生成內容 (UGC)**：提供書評、金句摘錄、讀書摘要功能，並可設定公開/私有。  
     * *商業價值*：建立內容護城河，成為平台核心資產。  
  3. **個人化 AI 分析**：每日根據使用者互動，生成個人化分析報告。  
     * *商業價值*：提供超越工具的「夥伴感」，提升用戶黏著度。  
  4. **Instagram 帳號綁定**：深度整合 IG，允許使用者連結個人檔案，利用其社群網絡進行破圈傳播。

### **2.2 TELL ME：您的即時智慧資訊中心**

* **核心理念**：一個整合式的即時智慧資訊中心 (Your Live Smart Information Hub)，解決使用者需在多個 App 間頻繁切換的痛點。  
* **核心互動體驗 (V5.0)**：  
  * **主畫面架構**：上方為水平滾動的「摘要卡片」（如天氣、股市、新聞），下方根據所選卡片，垂直呈現「區塊化列表」的詳細內容。  
  * **獨到之處**：由 AI 引擎進行分析、摘要與預警，從被動接收資訊進化到主動掌控。  
* **技術架構快照**：  
  * **前端開發**：Flutter  
  * **狀態管理**：GetX  
  * **UI 風格**：Smart Home Neumorphism  
  * **核心佈局**：ListView \+ GridView

### **2.3 coco Daily：您的每日特價雷達**

* **核心理念**：一個輕量級的每日特價資訊聚合與通知工具，專注於 Costco 等大型賣場。  
* **核心功能 (MVP)**：  
  1. **特價清單**：App 內以圖文列表展示每日特價商品。  
  2. **LINE 通知**：核心功能，使用者可一鍵授權 LINE Notify，每日自動接收精選特價品的推播通知。  
* **技術架構規劃**：  
  * **數據來源**：需要一個**網路爬蟲 (Scraper)**，定期抓取目標網站的特價資訊。  
  * **後端職責**：Node.js 或 Python，負責處理 API 請求與整合 LINE Notify API 的推播邏輯。

## **3\. BookMe 全功能後端進階架構**

這套架構的核心思想是**關注點分離 (Separation of Concerns)**，採用模組化與微服務理念，作為所有內容型 App 的統一後端。

### **3.1 核心技術選型 (Technology Stack)**

* **語言**：**TypeScript** \- 提升大型專案的穩定性與可維護性。  
* **後端框架**：**NestJS** \- 高度結構化的 Node.js 框架，天生鼓勵模組化與依賴注入。  
* **資料庫**：**MongoDB (NoSQL)** \- 適合處理非結構化、讀寫頻繁的使用者生成內容。  
* **部署平台**：**Google Cloud Platform (GCP)** \- 優先採用 Serverless 服務，專注於業務邏輯。

### **3.2 系統架構：拆分為七大核心服務**

我們的後端將由以下幾個可以獨立開發、獨立部署的微服務組成：

| 服務名稱 | 職責 | 部署方案 |
| :---- | :---- | :---- |
| **API 閘道 (API Gateway)** | 所有 App 請求的統一入口，負責路由、認證與代理 (如 TELL ME)。 | Google Cloud Run |
| **認證服務 (Auth Service)** | 處理使用者註冊、登入、核發 JWT、以及 Instagram OAuth 2.0 流程。 | Google Cloud Run |
| **使用者服務 (User Service)** | 管理使用者個人檔案 (Profile) 與追蹤 (Follow) 等社交關係。 | Google Cloud Run |
| **書籍服務 (Book Service)** | 管理書籍資料快取，處理心得、摘要、金句的 CRUD 與權限。 | Google Cloud Run |
| **推薦服務 (Recommendation)** | 封裝與 AI 模型 (如 Google Gemini API) 的所有互動，生成書單。 | Google Cloud Run |
| **分析服務 (Analysis Service)** | 背景工人 (Worker)，執行每日排程任務，生成個人化 AI 分析報告。 | Google Cloud Functions |
| **資料庫 (Database)** | 所有服務的統一資料儲存中心。 | MongoDB Atlas |


## **4\. GCP 實戰建構藍圖**

採用 **Serverless First (無伺服器優先)** 的核心理念，將架構落地。

### **4.1 實戰建構流程**

1. **階段一：GCP 環境初始化**  
   * 建立 GCP 專案，啟用計費，安裝 gcloud CLI。  
   * 啟用所需 API：Cloud Run, Cloud Build, Cloud Functions, Cloud Scheduler, Artifact Registry, Secret Manager。  
2. **階段二：搭建微服務 (以 auth-service 為例)**  
   * **容器化 (Containerization)**：為每個 NestJS 專案建立 Dockerfile。  
     \# Dockerfile  
     \# \--- 階段 1: 建置階段 \---  
     FROM node:18-alpine AS builder  
     WORKDIR /usr/src/app  
     COPY package\*.json ./  
     RUN npm install  
     COPY . .  
     RUN npm run build

     \# \--- 階段 2: 生產階段 \---  
     FROM node:18-alpine  
     COPY \--from=builder /usr/src/app/node\_modules ./node\_modules  
     COPY \--from=builder /usr/src/app/package\*.json ./  
     COPY \--from=builder /usr/src/app/dist ./dist  
     ENV NODE\_ENV=production  
     EXPOSE 3000  
     CMD \["node", "dist/main"\]

   * **密鑰管理**：在 MongoDB Atlas 建立資料庫，並將連線字串、JWT 密鑰等存放在 GCP 的 Secret Manager 中。  
   * **自動化部署 (CI/CD)**：為每個服務建立 cloudbuild.yaml，定義自動化建置與部署流程。  
     \# cloudbuild.yaml  
     steps:  
       \# 步驟 1: 建置容器映像檔  
       \- name: 'gcr.io/cloud-builders/docker'  
         args: \['build', '-t', 'asia-east1-docker.pkg.dev/$PROJECT\_ID/bookme-repo/auth-service:$COMMIT\_SHA', '.'\]

       \# 步驟 2: 推送映像檔至 Artifact Registry  
       \- name: 'gcr.io/cloud-builders/docker'  
         args: \['push', 'asia-east1-docker.pkg.dev/$PROJECT\_ID/bookme-repo/auth-service:$COMMIT\_SHA'\]

       \# 步驟 3: 部署至 Cloud Run  
       \- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'  
         entrypoint: 'gcloud'  
         args:  
           \- 'run'  
           \- 'deploy'  
           \- 'auth-service'  
           \- '--image=asia-east1-docker.pkg.dev/$PROJECT\_ID/bookme-repo/auth-service:$COMMIT\_SHA'  
           \- '--region=asia-east1'  
           \- '--platform=managed'  
           \- '--allow-unauthenticated'  
           \- '--set-secrets=MONGO\_URI=MONGO\_URI:latest,JWT\_SECRET=JWT\_SECRET:latest'

     images:  
       \- 'asia-east1-docker.pkg.dev/$PROJECT\_ID/bookme-repo/auth-service:$COMMIT\_SHA'

3. **階段三：建構背景任務 (analysis-service)**  
   * 開發 Cloud Function 處理每日分析邏輯。  
   * 使用 Cloud Scheduler 設定排程 (例如每天凌晨 3 點 0 3 \* \* \*)，定時觸發該 Function。  
4. **階段四：整合與擴展**  
   * 重複階段二的流程，部署所有微服務。  
   * 建構 API Gateway 服務，統一接收請求，並透過 GCP 內部 DNS 呼叫其他微服務。

## **5\. 結論：從「開發者」到「架構師」的思維轉變**

建立一個統一的後端伺服器，是從「App 開發者」轉變為「產品架構師」的關鍵一步。這套架構的核心優勢是巨大的：

* **更安全**：API 金鑰等敏感資訊不落地儲存在 App 中。  
* **更強大**：伺服器可以處理 AI 運算、排程任務等複雜商業邏輯。  
* **更有彈性**：前端與後端分離，可獨立更新演進。當單一服務負載過高時，只需為該服務擴展資源。  
* **更能擴展**：為未來更多元的商業模式（如會員制、進階 AI 功能、新產品線）奠定穩固的數位基礎建設。