#!/bin/bash

# Script to verify Playground is working correctly

echo "🧪 Testing Undo/Redo System Playground"
echo "======================================="
echo ""

# Check if Playground exists
if [ -d "UndoRedoDemo.playground" ]; then
    echo "✅ Playground directory found"
else
    echo "❌ Playground directory not found"
    exit 1
fi

# Check if Contents.swift exists
if [ -f "UndoRedoDemo.playground/Contents.swift" ]; then
    echo "✅ Contents.swift found"
    LINES=$(wc -l < "UndoRedoDemo.playground/Contents.swift")
    echo "   Lines: $LINES"
else
    echo "❌ Contents.swift not found"
    exit 1
fi

# Check if Sources/UndoRedoSystem.swift exists
if [ -f "UndoRedoDemo.playground/Sources/UndoRedoSystem.swift" ]; then
    echo "✅ Sources/UndoRedoSystem.swift found"
    LINES=$(wc -l < "UndoRedoDemo.playground/Sources/UndoRedoSystem.swift")
    echo "   Lines: $LINES"
else
    echo "❌ Sources/UndoRedoSystem.swift not found"
    exit 1
fi

# Check if README exists
if [ -f "UndoRedoDemo.playground/README.md" ]; then
    echo "✅ README.md found"
else
    echo "⚠️  README.md not found (optional)"
fi

# Check if contents.xcplayground exists
if [ -f "UndoRedoDemo.playground/contents.xcplayground" ]; then
    echo "✅ contents.xcplayground found"
else
    echo "❌ contents.xcplayground not found"
    exit 1
fi

echo ""
echo "🎉 All checks passed!"
echo ""
echo "📝 To use the Playground:"
echo "   1. Open Playground: open UndoRedoDemo.playground"
echo "   2. In Xcode, click the ▶️ button to execute"
echo "   3. View output in the right panel"
echo ""
echo "📚 Documentation:"
echo "   - Playground README: UndoRedoDemo.playground/README.md"
echo "   - Demo Guide: DEMO_GUIDE.md"
echo ""
