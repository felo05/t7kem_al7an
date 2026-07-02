#!/usr/bin/env python3
"""
Seed Results Collections with Test Data
=====================================
This script seeds the Firebase Firestore Results collections with random test data
to test the CheckStatusScreen functionality.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import random
import json

# Initialize Firebase Admin SDK
def initialize_firebase():
    try:
        # Try to get the default app
        app = firebase_admin.get_app()
        print("✅ Firebase app already initialized")
    except ValueError:
        # App doesn't exist, initialize it
        print("🔧 Initializing Firebase...")
        # You may need to download the service account key and update this path
        # For now, we'll use application default credentials
        try:
            cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(cred)
            print("✅ Firebase initialized with Application Default Credentials")
        except Exception as e:
            print(f"❌ Firebase initialization failed: {e}")
            print("💡 Make sure you have Firebase Admin SDK configured properly")
            return None
    
    return firestore.client()

# Collection names for results
COLLECTIONS = [
    'kg1ResultsFinal',
    'kg2ResultsFinal', 
    'kgGResultsFinal',
    'kgFResultsFinal',
    'oulaTanya1ResultsFinal',
    'oulaTanya2ResultsFinal',
    'oulaTanyaGResultsFinal',
    'oulaTanyaFResultsFinal',
    'taltaRaba1ResultsFinal',
    'taltaRaba2ResultsFinal',
    'taltaRabaGResultsFinal',
    'taltaRabaFResultsFinal',
    'khamsaSadsa1ResultsFinal',
    'khamsaSadsa2ResultsFinal',
    'khamsaSadsaGResultsFinal',
    'khamsaSadsaFResultsFinal',
]

# Sample church names (Arabic)
CHURCHES = [
    'كنيسة مار جرجس',
    'كنيسة العذراء مريم',
    'كنيسة مار مينا',
    'كنيسة الشهيد مار مرقس',
    'كنيسة القديس يوحنا',
    'كنيسة الأنبا أنطونيوس',
    'كنيسة الملاك ميخائيل',
    'كنيسة الأنبا بيشوي',
    'كنيسة القديسة دميانة',
    'كنيسة الأنبا صموئيل',
    'كنيسة مار بولس',
    'كنيسة الأنبا كيرلس',
    'كنيسة القديس موسى',
    'كنيسة الأنبا برسوم',
    'كنيسة مار تادرس'
]

# Sample contestant names (Arabic)
CONTESTANTS = [
    'أحمد محمد',
    'فاطمة علي',
    'محمد أحمد',
    'سارة محمد',
    'عمر خالد',
    'نور الهدى',
    'يوسف إبراهيم',
    'مريم سمير',
    'خالد أحمد',
    'نادية حسن',
    'إبراهيم عمر',
    'ليلى محمود',
    'سمير جمال',
    'هدى فؤاد',
    'طارق سعد'
]

def create_random_document(collection_name, doc_id):
    """Create a random document for testing"""
    church = random.choice(CHURCHES)
    contestant = random.choice(CONTESTANTS)
    
    # Generate random scores for different categories
    memorization_score = random.randint(70, 100)
    understanding_score = random.randint(65, 95)
    presentation_score = random.randint(60, 90)
    
    # Calculate total
    total = memorization_score + understanding_score + presentation_score
    
    document = {
        'church': church,
        'contestant': contestant,
        'scores': {
            'memorization': memorization_score,  # حفظ
            'understanding': understanding_score,  # فهم
            'presentation': presentation_score   # إلقاء
        },
        'total': total,
        'rank': 0,  # Will be calculated later
        'timestamp': firestore.SERVER_TIMESTAMP,
        'collection_category': collection_name.replace('Results', '')
    }
    
    return document

def seed_collection(db, collection_name, num_documents=5):
    """Seed a specific collection with random documents"""
    print(f"🌱 Seeding {collection_name} with {num_documents} documents...")
    
    documents = []
    for i in range(num_documents):
        doc_id = f"contestant_{i+1}"
        doc_data = create_random_document(collection_name, doc_id)
        documents.append((doc_id, doc_data))
    
    # Sort by total score to assign ranks
    documents.sort(key=lambda x: x[1]['total'], reverse=True)
    
    # Assign ranks and save to Firestore
    batch = db.batch()
    for rank, (doc_id, doc_data) in enumerate(documents, 1):
        doc_data['rank'] = rank
        doc_ref = db.collection(collection_name).document(doc_id)
        batch.set(doc_ref, doc_data)
    
    # Commit the batch
    batch.commit()
    
    # Print summary
    winner = documents[0][1]
    print(f"   ✅ Added {len(documents)} documents")
    print(f"   🏆 Winner: {winner['contestant']} from {winner['church']} (Total: {winner['total']})")
    
    return len(documents)

def main():
    """Main seeding function"""
    print("🚀 Starting Results Collections Seeding...")
    print("=" * 50)
    
    # Initialize Firebase
    db = initialize_firebase()
    if not db:
        print("❌ Failed to initialize Firebase. Exiting.")
        return
    
    total_documents = 0
    
    # Seed each collection
    for collection_name in COLLECTIONS:
        try:
            # Random number of documents per collection (3-8)
            num_docs = random.randint(3, 8)
            docs_added = seed_collection(db, collection_name, num_docs)
            total_documents += docs_added
            print()
        except Exception as e:
            print(f"❌ Error seeding {collection_name}: {e}")
            continue
    
    print("=" * 50)
    print(f"🎉 Seeding completed!")
    print(f"📊 Total documents created: {total_documents}")
    print(f"📂 Collections seeded: {len(COLLECTIONS)}")
    print("\n💡 You can now test the CheckStatusScreen to see the results!")

if __name__ == "__main__":
    main()
