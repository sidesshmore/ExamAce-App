
# 📚 ExamAce – Your Smart Study Companion for University Exams

## Introduction

![Flutter](https://img.shields.io/badge/Flutter-white?style=for-the-badge&logo=flutter&logoColor=02569B)
![Mistral](https://img.shields.io/badge/Mistral%20LLM-1A1A1A?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScyNCcgaGVpZ2h0PScyNCc+PHBhdGggZD0nTTEyIDJBMTAgMTAgMCAwMCAyIDExYzAgNS41IDQuNSAxMCAxMCAxMCA1LjUgMCAxMC00LjUgMTAtMTBBMTAgMTAgMCAwMCAxMiAyWk0xMSAxNkg5di0yaDJ2MlpNMTUgMTZoLTJ2LTJoMnYyWk0xMiAxMmExIDEgMCAxIDEtMS0xIDEgMSAwIDAgMSAxIDFaJyBmaWxsPSd3aGl0ZScvPjwvc3ZnPg==&logoColor=white)
![FAISS](https://img.shields.io/badge/FAISS-blue?style=for-the-badge)
![Supabase](https://img.shields.io/badge/Supabase-181818?style=for-the-badge&logo=supabase&logoColor=white)

**ExamAce** is a Flutter-based mobile application that helps engineering students find precise, textbook-based answers to academic questions. By leveraging **RAG (Retrieval-Augmented Generation)** using **Mistral LLM**, **nomic embeddings**, and **FAISS vector databases**, ExamAce makes university exam prep smarter and more efficient.

---

## 🚀 Overview

Struggling to find answers from the *prescribed university textbooks*?  
**ExamAce** solves that by turning textbooks into intelligent, searchable assistants.

### The Traditional Problems:
- Time-consuming manual search through bulky books  
- Limited online resources tailored to your syllabus  
- Uncertainty about the credibility of sources  

### ExamAce Advantages:
- 🔍 **Precise Retrieval** from *university-recommended textbooks*  
- 🤖 **Smart Responses** generated via **Mistral LLM**  
- 📚 **Always Syllabus-Aligned** – no irrelevant or generic content  

---

## 📱 App Screenshots

*(Add your app screenshots)*
---

## 🎯 Key Features

### ✅ **Textbook-Based Answers**
- Get answers from actual textbooks recommended by your university  
- Powered by high-quality nomic embeddings and FAISS vector search  

### ✅ **RAG-Powered Q&A System**
- Retrieve accurate context from embedded book data  
- Generate clear and concise answers using **Mistral LLM**  

### ✅ **Fast & Relevant Retrieval**
- Lightning-fast search from large textbook chunks  
- Prioritized content based on semantic similarity  

### ✅ **Bookmark Support**
- Save important questions and answers for quick access later  
- Organize your study material and build your own answer library  

### ✅ **Clean & User-Friendly Interface**
- Minimalist UI for distraction-free studying  
- Easily ask questions by typing or voice  

---


## 🏗️ Architecture of ExamAce

![WhatsApp Image 2025-04-18 at 20 16 18](https://github.com/user-attachments/assets/bd29a07f-4cf9-4255-bb43-83fb5b17ac86)

### 1️⃣ **Preprocessing of Data**  
The first stage focuses on preparing data to ensure high-quality responses. The system utilizes a diverse range of academic resources, including:

- 📘 Reference books  
- 📄 Lecture notes  
- 📊 Professor presentations (PPTs)  
- 📝 Previous year exam questions  

These materials are processed and cleaned for embedding.


### 2️⃣ **Text Embedding**  
The textual data is transformed into vector embeddings using the **nomic-embed-text** model. To enhance efficiency:

- ✅ **Binary and Scalar Embedding Quantization** techniques are applied  
- 🚀 These methods improve **retrieval speed** and reduce **computational cost**  
- 🧠 Embeddings capture the **semantic meaning** of academic content


### 3️⃣ **Data Retrieval and Generation**  
Once the data is embedded and stored, the system enters the query-processing stage using a **RAG (Retrieval-Augmented Generation)** pipeline.


### 4️⃣ **Query Embedding**  
When a student submits a query:

- 🔄 It is converted into a **vector embedding** using the same model  
- 🧩 This ensures **semantic consistency** with the stored data


### 5️⃣ **Relevant Data Retrieval**  
- 🔍 The system queries the **FAISS vector database**  
- 📚 It fetches the **most relevant chunks** based on the query embedding  
- 🧾 These results are compiled into a **context-rich prompt**


### 6️⃣ **LLM Response Generation**  
- 🤖 The final prompt is processed by a **Mistral LLM agent**  
- ✍️ It generates a **coherent, accurate, and contextualized answer**

---


## ⚙️ Sequence Diagram

![WhatsApp Image 2025-04-11 at 23 16 47](https://github.com/user-attachments/assets/98ae7281-caa9-47de-a6a6-630481d6cc85)

---

## 🛠 Getting Started

```bash
git clone https://github.com/sidesshmore/ExamAce-App
cd ExamAce-App
flutter pub get
flutter run
```

---

## 🎓 Built for Students, by Students

**ExamAce** is more than an app – it's your academic partner. Whether you're cramming the night before or preparing weeks in advance, **ExamAce** makes sure your answers come straight from the source.

> Study smarter, not harder – with **ExamAce**. 🚀

---

Want help adding project badges, demo video section, or deploying a landing page for it?
