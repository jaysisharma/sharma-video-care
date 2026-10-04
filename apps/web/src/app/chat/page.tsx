"use client";

import React, { useEffect, useState, useRef, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import {
  collection,
  query,
  where,
  onSnapshot,
  addDoc,
  doc,
  updateDoc,
  orderBy,
  getDoc,
} from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth } from "../../context/AuthContext";
import { Conversation, ChatMessage, UserRole } from "@sharmavideocare/shared";
import { MessageSquare, Send, Paperclip, CheckCheck, Clock, User, ShieldAlert, Hammer } from "lucide-react";

function ChatContent() {
  const searchParams = useSearchParams();
  const contextIdParam = searchParams.get("contextId");

  const { user, role } = useAuth();
  const userId = user?.id || "cust-janakpur-01";

  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [activeConvId, setActiveConvId] = useState<string | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [newMessageText, setNewMessageText] = useState("");
  const [attachmentUrl, setAttachmentUrl] = useState("");
  const [showAttachmentInput, setShowAttachmentInput] = useState(false);
  const [sending, setSending] = useState(false);

  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  // Load conversations
  useEffect(() => {
    let qConv;
    if (role === "admin") {
      // Admins see all conversations
      qConv = query(collection(db, "conversations"));
    } else {
      // Customers and Technicians see conversations where they are a participant
      qConv = query(
        collection(db, "conversations"),
        where("participantIds", "array-contains", userId)
      );
    }

    const unsub = onSnapshot(qConv, (snap) => {
      const list: Conversation[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as Conversation));
      const sorted = list.sort(
        (a, b) => new Date(b.lastMessageAt).getTime() - new Date(a.lastMessageAt).getTime()
      );
      setConversations(sorted);

      // Auto-select conversation matching param or first conversation
      if (contextIdParam) {
        const matching = sorted.find((c) => c.contextId === contextIdParam);
        if (matching) {
          setActiveConvId(matching.id);
          return;
        }
      }
      if (!activeConvId && sorted.length > 0) {
        setActiveConvId(sorted[0].id);
      }
    });

    return () => unsub();
  }, [userId, role, contextIdParam]);

  // Load messages for active conversation
  useEffect(() => {
    if (!activeConvId) {
      setMessages([]);
      return;
    }

    const qMsgs = query(
      collection(db, "conversations", activeConvId, "messages"),
      orderBy("createdAt", "asc")
    );

    const unsub = onSnapshot(qMsgs, (snap) => {
      const list: ChatMessage[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as ChatMessage));
      setMessages(list);
      setTimeout(() => messagesEndRef.current?.scrollIntoView({ behavior: "smooth" }), 100);
    });

    return () => unsub();
  }, [activeConvId]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if ((!newMessageText.trim() && !attachmentUrl.trim()) || !activeConvId) return;

    setSending(true);
    try {
      const msgData: Omit<ChatMessage, "id"> = {
        conversationId: activeConvId,
        senderId: userId,
        senderName: user?.name || "User",
        senderRole: role as UserRole,
        text: newMessageText.trim(),
        attachmentUrls: attachmentUrl.trim() ? [attachmentUrl.trim()] : [],
        createdAt: new Date().toISOString(),
      };

      await addDoc(collection(db, "conversations", activeConvId, "messages"), msgData);

      // Update conversation metadata
      await updateDoc(doc(db, "conversations", activeConvId), {
        lastMessageText: newMessageText.trim() || "[Attachment]",
        lastMessageAt: new Date().toISOString(),
      });

      setNewMessageText("");
      setAttachmentUrl("");
      setShowAttachmentInput(false);
    } catch (err) {
      console.error("Message send failed:", err);
    } finally {
      setSending(false);
    }
  };

  const activeConv = conversations.find((c) => c.id === activeConvId);

  return (
    <div className="container" style={{ padding: "2.5rem 1.25rem" }}>
      <div style={{ marginBottom: "1.5rem" }}>
        <h1 style={{ fontSize: "1.85rem", fontWeight: 800 }}>Service & Support Chat</h1>
        <p style={{ color: "var(--color-muted)", fontSize: "0.9rem" }}>
          Direct communication linked to your repair jobs, product orders, and service inquiries.
        </p>
      </div>

      <div
        className="card"
        style={{
          display: "grid",
          gridTemplateColumns: "320px 1fr",
          height: "640px",
          padding: 0,
          overflow: "hidden",
        }}
      >
        {/* Left: Conversation List */}
        <div style={{ borderRight: "1px solid var(--color-border)", display: "flex", flexDirection: "column", background: "#FAF8F5" }}>
          <div style={{ padding: "1rem", borderBottom: "1px solid var(--color-border)", fontWeight: 700, fontSize: "0.95rem" }}>
            Conversations ({conversations.length})
          </div>

          <div style={{ flex: 1, overflowY: "auto" }}>
            {conversations.length === 0 ? (
              <div style={{ padding: "2rem 1rem", textAlign: "center", color: "var(--color-muted)", fontSize: "0.85rem" }}>
                No active conversations yet. Submitting a repair or order automatically opens a support thread.
              </div>
            ) : (
              conversations.map((c) => (
                <div
                  key={c.id}
                  onClick={() => setActiveConvId(c.id)}
                  style={{
                    padding: "1rem",
                    borderBottom: "1px solid var(--color-border)",
                    cursor: "pointer",
                    background: activeConvId === c.id ? "#FFFFFF" : "transparent",
                    borderLeft: activeConvId === c.id ? "3px solid var(--color-primary)" : "3px solid transparent",
                  }}
                >
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "0.2rem" }}>
                    <strong style={{ fontSize: "0.9rem", color: "var(--color-ink)", maxWidth: "180px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                      {c.contextTitle || "Support Chat"}
                    </strong>
                    <span style={{ fontSize: "0.72rem", color: "var(--color-muted)" }}>
                      {new Date(c.lastMessageAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                    </span>
                  </div>

                  <div style={{ fontSize: "0.78rem", color: "var(--color-muted)", textTransform: "capitalize", marginBottom: "0.3rem" }}>
                    Context: {c.contextType.replace("_", " ").toLowerCase()}
                  </div>

                  <p style={{ fontSize: "0.82rem", color: "var(--color-muted)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                    {c.lastMessageText || "No messages yet"}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right: Message Stream */}
        {activeConv ? (
          <div style={{ display: "flex", flexDirection: "column", height: "100%", background: "var(--color-surface)" }}>
            {/* Thread Header */}
            <div style={{ padding: "1rem 1.5rem", borderBottom: "1px solid var(--color-border)", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <h3 style={{ fontSize: "1.05rem", fontWeight: 700 }}>{activeConv.contextTitle}</h3>
                <span style={{ fontSize: "0.78rem", color: "var(--color-muted)" }}>
                  Linked Reference: #{activeConv.contextId?.slice(0, 8)}
                </span>
              </div>
              <span className="badge badge-success">Live Realtime</span>
            </div>

            {/* Messages Area */}
            <div style={{ flex: 1, overflowY: "auto", padding: "1.5rem", display: "flex", flexDirection: "column", gap: "1rem" }}>
              {messages.length === 0 ? (
                <div style={{ textAlign: "center", color: "var(--color-muted)", margin: "auto", fontSize: "0.9rem" }}>
                  Start a conversation regarding this service or order.
                </div>
              ) : (
                messages.map((m) => {
                  const isMe = m.senderId === userId;
                  return (
                    <div
                      key={m.id}
                      style={{
                        alignSelf: isMe ? "flex-end" : "flex-start",
                        maxWidth: "70%",
                      }}
                    >
                      <div style={{ fontSize: "0.75rem", color: "var(--color-muted)", marginBottom: "0.2rem", textAlign: isMe ? "right" : "left" }}>
                        <strong>{m.senderName}</strong>{" "}
                        <span style={{ textTransform: "uppercase", fontSize: "0.68rem" }}>({m.senderRole})</span>
                      </div>

                      <div
                        style={{
                          padding: "0.75rem 1rem",
                          borderRadius: "var(--radius-sm)",
                          background: isMe ? "var(--color-primary)" : "#F2EDE4",
                          color: isMe ? "#FFFFFF" : "var(--color-ink)",
                          fontSize: "0.9rem",
                          lineHeight: 1.4,
                        }}
                      >
                        {m.text}

                        {m.attachmentUrls && m.attachmentUrls.length > 0 && (
                          <div style={{ marginTop: "0.5rem" }}>
                            <a
                              href={m.attachmentUrls[0]}
                              target="_blank"
                              rel="noreferrer"
                              style={{ color: isMe ? "#FFE3CC" : "var(--color-primary)", textDecoration: "underline", fontSize: "0.82rem" }}
                            >
                              📎 View Attachment ↗
                            </a>
                          </div>
                        )}
                      </div>

                      <div style={{ fontSize: "0.7rem", color: "var(--color-muted)", marginTop: "0.2rem", textAlign: isMe ? "right" : "left" }}>
                        {new Date(m.createdAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
                      </div>
                    </div>
                  );
                })
              )}
              <div ref={messagesEndRef} />
            </div>

            {/* Input Bar */}
            <form onSubmit={handleSendMessage} style={{ borderTop: "1px solid var(--color-border)", padding: "1rem", background: "#FAF8F5" }}>
              {showAttachmentInput && (
                <div style={{ marginBottom: "0.75rem" }}>
                  <input
                    type="url"
                    className="form-input"
                    placeholder="Attachment image/file link (https://...)"
                    value={attachmentUrl}
                    onChange={(e) => setAttachmentUrl(e.target.value)}
                  />
                </div>
              )}

              <div style={{ display: "flex", gap: "0.5rem" }}>
                <button
                  type="button"
                  onClick={() => setShowAttachmentInput(!showAttachmentInput)}
                  className="btn btn-secondary btn-sm"
                  title="Attach link"
                >
                  <Paperclip size={16} />
                </button>

                <input
                  type="text"
                  className="form-input"
                  placeholder="Type your message..."
                  value={newMessageText}
                  onChange={(e) => setNewMessageText(e.target.value)}
                />

                <button
                  type="submit"
                  className="btn btn-primary btn-sm"
                  disabled={sending || (!newMessageText.trim() && !attachmentUrl.trim())}
                >
                  <Send size={16} />
                </button>
              </div>
            </form>
          </div>
        ) : (
          <div style={{ display: "flex", alignItems: "center", justifyContent: "center", color: "var(--color-muted)" }}>
            Select a conversation on the left to start chatting.
          </div>
        )}
      </div>
    </div>
  );
}

export default function ChatPage() {
  return (
    <Suspense fallback={<div className="container" style={{ padding: "4rem 0", textAlign: "center" }}>Loading chat...</div>}>
      <ChatContent />
    </Suspense>
  );
}
