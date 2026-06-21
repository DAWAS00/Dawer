# Dawer App - Presentation Content

This document contains structured talking points for the Dawer app presentation, organized according to the required categories.

## 1. Description of the current situation and opportunity

* **Current Situation:** Currently, waste management and recycling processes are highly fragmented. Households and local businesses generate significant recyclable waste (plastic, cardboard, metal) but often throw it away due to the lack of a convenient, incentivized disposal method. Meanwhile, recycling companies struggle to source well-sorted, high-quality recyclable materials efficiently.
* **Opportunity:** There is a massive opportunity to digitize the "circular economy." By creating a localized digital ecosystem, we can financially incentivize people to recycle, create gig-economy jobs for local drivers, and provide recycling facilities with a steady, categorized stream of materials. 

## 2. Related work

* **Traditional Methods:** Municipal waste collection is rigid, lacks sorting at the source, and offers zero financial incentive to the consumer.
* **General Marketplaces (e.g., Facebook Marketplace, OpenSooq):** People sometimes sell scrap on these platforms, but they lack specific workflows for waste weight, transport logistics, and recycling categories.
* **Other Eco-Apps:** While some apps exist to educate users about recycling, very few provide an end-to-end operational pipeline that connects the **Supplier**, the **Driver**, and the **Recycling Company** in one unified marketplace.

## 3. Problem statement

* **Lack of Incentive:** Individuals and small businesses have no motivation to sort and save their recyclables.
* **Logistical Gap:** Even if someone wants to recycle, transporting raw materials to a recycling plant is difficult and costly.
* **Information Gap:** Users often don't know how to properly classify their waste or determine its value in the scrap market.

## 4. Problem solution

* **The "Dawer" App:** A comprehensive, multi-sided platform designed specifically for the recycling ecosystem.
* It introduces three distinct user roles:
    1. **Suppliers (Individuals/Stores):** Can list their sorted recyclables on a marketplace and earn rewards/points.
    2. **Drivers:** Can browse available pickup jobs, accept them, and earn money for transporting materials.
    3. **Recycling Companies:** Can easily browse the marketplace to buy raw materials in bulk directly from suppliers or through drivers.

## 5. Project objectives

* **Environmental:** Reduce landfill waste by making recycling highly accessible and rewarding.
* **Economic:** Create a marketplace where waste becomes a commodity, providing income for suppliers and drivers.
* **Technological:** Streamline the entire lifecycle of waste collection using modern mobile tech, geolocation, and artificial intelligence.
* **User Experience:** Deliver a seamless, Arabic-first user interface (with features like Dark/Light mode) to encourage daily usage.

## 6. AI Core: Bridging Vision & Reality

* **Automated Classification:** Using AI Computer Vision (Google ML Kit Image Labeling), Dawer allows users to simply take a picture of their waste. The AI bridges the gap between the physical item and the digital marketplace by automatically identifying the material (e.g., Plastic, Cardboard, Glass).
* **Dawa Chatbot:** An integrated smart assistant that helps users understand recycling best practices, guides them through the app, and answers queries about sorting, bridging the knowledge gap.

## 7. Technology and tools used

* **Frontend Framework:** Flutter (Dart) for building a high-performance, cross-platform mobile application.
* **State Management:** Provider (`ChangeNotifierProvider`) for efficient app-wide state handling.
* **AI & Machine Learning:** Google ML Kit for on-device image labeling and AI chat integration.
* **Mapping & Location:** `flutter_map`, `geolocator`, and `latlong2` for driver routing and supplier address targeting.
* **Local Storage:** `shared_preferences` for persisting user settings like Dark Mode and session tokens.
* **UI/UX Tools:** Google Fonts (Cairo for Arabic typography), Custom Material Design theming.

## 8. Conclusion and future work

* **Conclusion:** Dawer successfully transforms waste management from a chore into a rewarding, community-driven marketplace. By uniting suppliers, drivers, and recyclers under one AI-powered platform, it proves that technology can drive sustainable environmental practices.
* **Future Work:** 
    * **IoT Integration:** Connecting the app with "Smart Bins" that automatically weigh and register waste.
    * **Advanced AI:** Upgrading the vision model to detect material grades (e.g., distinguishing between PET and HDPE plastics).
    * **B2B Expansion:** Partnering directly with municipal governments and larger enterprise corporations for city-wide adoption.
    * **Digital Wallet Integration:** Allowing direct withdrawal of earned points/money to local mobile wallets (e.g., CliQ, Zain Cash).
