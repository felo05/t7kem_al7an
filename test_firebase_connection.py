#!/usr/bin/env python3
"""
Simple script to test Firebase connection and authentication
Use this to troubleshoot connection issues before running the main script
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
import sys

def test_firebase_connection():
    """Test Firebase connection with minimal operations"""
    try:
        print("🔥 Testing Firebase Connection")
        print("=" * 50)
        
        # Check if service account key exists
        cred_path = "assets/t7kem-al7an-firebase-adminsdk-fbsvc-d28c9e62f0.json"
        
        if not os.path.exists(cred_path):
            print(f"❌ Service account key not found: {cred_path}")
            return False
        
        print(f"✅ Service account key found: {cred_path}")
        
        # Initialize Firebase
        print("🔄 Initializing Firebase...")
        
        try:
            firebase_admin.get_app()
            print("🔄 Deleting existing Firebase app...")
            firebase_admin.delete_app(firebase_admin.get_app())
        except ValueError:
            pass
        
        cred = credentials.Certificate(cred_path)
        app = firebase_admin.initialize_app(cred)
        print("✅ Firebase app initialized")
        
        # Test Firestore connection
        print("🔄 Testing Firestore connection...")
        db = firestore.client()
        
        # Try to list collections (minimal operation)
        print("🔄 Listing existing collections...")
        collections = list(db.collections())
        print(f"✅ Found {len(collections)} existing collections:")
        
        for i, collection in enumerate(collections[:10], 1):  # Show first 10
            print(f"   {i}. {collection.id}")
        
        if len(collections) > 10:
            print(f"   ... and {len(collections) - 10} more")
        
        # Test document creation (minimal test)
        print("🔄 Testing document creation...")
        test_ref = db.collection('_test_connection').document('test')
        test_ref.set({
            'test': True,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print("✅ Test document created")
        
        # Read it back
        print("🔄 Testing document reading...")
        doc = test_ref.get()
        if doc.exists:
            print("✅ Test document read successfully")
        else:
            print("❌ Could not read test document")
            return False
        
        # Clean up test document
        print("🔄 Cleaning up test document...")
        test_ref.delete()
        print("✅ Test document deleted")
        
        print("\n🎉 Firebase connection test PASSED!")
        print("You can now run the main collection creation script.")
        return True
        
    except Exception as e:
        print(f"\n❌ Firebase connection test FAILED: {e}")
        
        # Provide troubleshooting guidance
        error_str = str(e).lower()
        if "invalid jwt signature" in error_str or "invalid_grant" in error_str:
            print("\n🔧 Troubleshooting JWT Signature Error:")
            print("1. Download a new service account key:")
            print("   - Go to Firebase Console > Project Settings > Service Accounts")
            print("   - Click 'Generate new private key'")
            print("   - Replace the file in assets/ folder")
            print("2. Check your system clock synchronization")
            print("3. Ensure stable internet connection")
        elif "timeout" in error_str:
            print("\n🔧 Troubleshooting Connection Timeout:")
            print("1. Check internet connection")
            print("2. Try using a different network or VPN")
            print("3. Check firewall/antivirus settings")
        
        return False

if __name__ == "__main__":
    success = test_firebase_connection()
    sys.exit(0 if success else 1)
